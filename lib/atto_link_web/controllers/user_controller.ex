defmodule AttoLinkWeb.UserController do
  use AttoLinkWeb, :controller

  alias AttoLink.Accounts
  alias AttoLink.Accounts.User
  alias AttoLink.Payments
  alias AttoLink.Auth
  alias AttoLink.Repo
  action_fallback AttoLinkWeb.FallbackController


  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "show.json", user: user)
  end

  def create(conn, %{"user" => user_params, "payment" => %{"payment_method_id" => pm_id, "plan" => plan_id}}) do
    IO.puts "hello world"
    with {:ok, %User{email: email, id: id} = user} <- Accounts.create_user(user_params),
         {:ok, %Stripe.Customer{id: customer_id} = customer} <- Stripe.Customer.create(%{email: email, payment_method: pm_id}),
         {:ok, %Stripe.Subscription{id: subscription_id, }} <-
           Stripe.Subscription.create(%{
             customer: customer,
             items: [%{plan: plan_id}],
             default_payment_method: pm_id
           }),

           {:ok, %Stripe.Plan{nickname: nickname}} <- Stripe.Plan.retrieve(plan_id),
           {:ok, %User{} = user} <- Accounts.update_user(user, %{customer_id: customer_id, plan: String.downcase(nickname) |> convert_to_atom}),
           {:ok, %Payments.Subscription{}} <-
             Payments.create_subscription(%{subscription_id: subscription_id,
             customer_id: customer_id,
             user_id: id,
             nickname: String.downcase(nickname) |> convert_to_atom}),
           {:ok, _permissions} <- AttoLink.Security.create_permissions(%{user_id: id})
           do
      IO.inspect user

      conn
      |> put_status(:created)
      |> verify_user(user)
    else
      {:error, %Stripe.Error{code: code, message: message}} ->
        IO.inspect code
        IO.puts message
        conn
        |> send_resp(500, Poison.encode!(%{code: code, message: message}))
      err -> err
    end
  end

  def create(conn, %{"user" => user_params}) do
    IO.puts "inside create lol"
    with {:ok, %User{id: id} = user} <- Accounts.create_user(user_params),
         {:ok, _permissions} <- AttoLink.Security.create_permissions(%{user_id: id})
    do
      conn
      |> put_status(:created)
      |> verify_user(user)
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
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, _params) do
    with %User{} = user <- Guardian.Plug.current_resource(conn),
         {:ok, %User{}} <- Accounts.delete_user(user) do
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
          |>put_status(:ok)
          |> put_view(AttoLinkWeb.UserView)
          |> render(:show, user: user)
        else
          nil ->
            conn
            |> resp(401, Poison.encode! %{message: :token_invalid})
            |> send_resp()
        end
  end

  defp convert_to_atom(atom) do
    try do
      String.to_existing_atom(atom)
    rescue
      ArgumentError -> String.to_atom(atom)
    end

  end


end
