defmodule AttoLinkWeb.UserController do
  use AttoLinkWeb, :controller
  require Logger
  alias AttoLink.Accounts
  alias AttoLink.Accounts.User
  alias AttoLink.Payments
  alias AttoLink.Auth
  alias AttoLink.Repo
  import Poison
  action_fallback AttoLinkWeb.FallbackController

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    user = user |> Repo.preload(:subscription)
    render(conn, "show.json", user: user)
  end

  def create(conn, %{
        "user" => %{"email" => email} = user_params,
        "payment" => %{"payment_method_id" => pm_id, "plan" => price_id}
      }) do
    Logger.info("signing up a new user");
    with {:ok, %Stripe.Customer{id: customer_id} = customer} <-
      Stripe.Customer.create(%{email: email, payment_method: pm_id}),
         {:ok, %User{id: id} = user} <-
           Accounts.create_user(user_params |> Enum.into(%{"customer_id" => customer_id})),
         {:ok, %Stripe.Subscription{id: subscription_id}} <-
           Stripe.Subscription.create(%{
             customer: customer,
             items: [%{price: price_id}],
             default_payment_method: pm_id
           }),
         {:ok, %Payments.Subscription{}} <-
           Payments.create_subscription(%{
             subscription_id: subscription_id,
             customer_id: customer_id,
             user_id: id,
           }),
         {:ok, _permissions} <- AttoLink.Security.create_permissions(%{user_id: id}) do

      conn
      |> put_status(:created)
      |> verify_user(user)
    else
      {:error, %Stripe.Error{code: code, message: message} = stripe_error} ->
        conn
        |> send_resp(500, Poison.encode!(%{code: code, message: message}))

      err ->
        Logger.info("an error occured when signing up a user #{inspect(err)}")
        err
    end
  end

  def create(conn, %{"user" => %{"email" => email} = user_params, "payments" => %{"plan" => price_id}} = _params) do
    Logger.info("creating a user without payment id")
    with {:ok, %Stripe.Customer{id: customer_id}} <- Stripe.Customer.create(%{email: email}),
        {:ok, %User{id: id} = user} <- Accounts.create_user(user_params |> Enum.into(%{"customer_id" => customer_id})),
         {:ok, %Stripe.Subscription{id: subscription_id}} <- Stripe.Subscription.create(%{customer: customer_id, items: [%{price: price_id}]}),
         {:ok, %Payments.Subscription{}} <-
           Payments.create_subscription(%{
             user_id: id,
             plan_id: price_id,
             subscription_id: subscription_id,
             customer_id: customer_id,
             nickname: :free
           }),
          {:ok, :sendgrid} <- send_email(user)
         do


      conn
      |> put_status(:created)
      |> verify_user(user)

         else

          {:error, :sendgrid, error} ->
               conn
               |> send_resp(:internal_server_error, encode!(%{code: :sendgrid_error, message: "Something went wrong when sending your confirmation email.
                You're account has been created but you'll have to login manually and request resending a confirmation email there."}))

          {:error, %Stripe.Error{code: :network_error}} ->
              conn
              |> send_resp(:internal_server_error, encode!(%{code: :payment_error}, message: "The network seemed to be down when registering your plan with our plan provider. You're account is created but you'll need to log in manually."))
          {:error, %Stripe.Error{}} = error ->
              Logger.error("stripe error has occured inspect: #{inspect(error)}")
              conn
              |> send_resp(:internal_server_error, encode!(%{code: :payment_error, message: "Something went wrong when registering your plan. Your account has been created, but you'd have to log in manually and update your plan. "}
              ))
           error ->
               Logger.error("An error occured when signing up this user #{inspect(error)}")
               error
    end
  end

  defp send_email(%AttoLink.Accounts.User{email: email} = user) do
    with {:ok, %AttoLink.Comms.ConfirmEmail{id: id}} <- AttoLink.Comms.create_email(%{user: user}),
         :ok <- AttoLink.Comms.send_confirm_email(email: email, id: id)
         do
           {:ok, :sendgrid}
         else
          err ->

            {:error, :sendgrid, err}
         end
  end

  def login(conn, %{"user" => %{"email" => email, "password" => password}} = _params) do
    with %User{} = user <- Accounts.get_by(email: email) do
      conn
      |> put_status(:ok)
      |> verify_user(%{user | password: password})
    else
      nil ->
        conn
        |> put_status(:unauthorized)
        |> put_view(AttoLinkWeb.ErrorView)
        |> render(:login)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id) |> Repo.preload(:subscription)

    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id) |> Repo.preload(:subscription)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, _params) do


    with %User{} = user <- Guardian.Plug.current_resource(conn),
          {:ok, %User{}} <- delete_user(user) do
      send_resp(conn, :no_content, "")
    else

      nil ->
        conn
        |> resp(
          404,
          Poison.encode!(%{
            message: "This user does not exist or has already been deleted",
            response_code: :does_not_exist
          })
        )
        |> send_resp()
        |> halt()
      {:error, %Stripe.Error{} = stripe_error} ->
        conn
        |> resp(500, Poison.encode!(%{
            message: "An error occured when deleting your subscription, try again later",
            responde_code: :internal_server_error
        }))
      end
  end

  defp delete_user(%User{customer_id: nil} = user) do
    with {:ok, user} <- Accounts.delete_user(user) do
      {:ok, user}
    else
      error
        -> error
    end
  end

  defp delete_user(%User{customer_id: customer_id} = user) do
    with {:ok, _customer} <- Stripe.Customer.delete(customer_id),
         {:ok, user} <- Accounts.delete_user(user) do
          {:ok, user}
         else
          error
            -> error
    end
  end

  @spec verify_user(conn :: Plug.Conn.t(), user :: User.t()) :: Plug.Conn.t()
  defp verify_user(conn, %User{} = user) do
    with {:ok, _reply} <- Accounts.authenticate_user(user),
         conn <- AttoLink.Auth.Guardian.Plug.sign_in(conn, user),
         token <- AttoLink.Auth.Guardian.Plug.current_token(conn) do
      conn
      |> put_view(AttoLinkWeb.UserView)
      |> render(:login, user: user, token: token)
    else
      err ->
        err
    end
  end

  def check_token(conn, _params) do
    with %User{} = user <- Auth.Guardian.Plug.current_resource(conn) do
      user = user |> Repo.preload([:subscription])

      conn
      |> put_status(:ok)
      |> put_view(AttoLinkWeb.UserView)
      |> render(:show, user: user)
    else
      nil ->
        conn
        |> resp(401, Poison.encode!(%{message: :token_invalid}))
        |> send_resp()
    end
  end


end
