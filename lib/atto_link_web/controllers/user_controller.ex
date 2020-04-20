defmodule AttoLinkWeb.UserController do
  use AttoLinkWeb, :controller

  alias AttoLink.Accounts
  alias AttoLink.Accounts.User
  action_fallback AttoLinkWeb.FallbackController

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "show.json", user: user)
  end

  def create(conn, %{"user" => user_params, "payment" => %{payment_method: pm_id, plan: plan_id}}) do
    with {:ok, %User{email: email} = user} <- Accounts.create_user(user_params),
         {:ok, %Stripe.Customer{id: id} = customer} <- Stripe.Customer.create(%{email: email}),
         {:ok, %User{}} <- Accounts.update_user(user, %{customer_id: id}),
         {:ok, %Stripe.Subscription{}} <-
           Stripe.Subscription.create(%{
             customer: customer,
             items: [%{plan: plan_id}],
             default_payment_method: pm_id
           }) do
      conn
      |> put_status(:created)
      |> verify_user(user)
    else
      {:error, %Stripe.Error{code: code, message: message}} ->
        conn
        |> send_resp(code, Poison.encode!(%{message: message}))
    end
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> verify_user(user)
    end
  end

  def login(conn, %{"user" => %{"email" => email, "password" => password}} = _user) do
    with user <- Accounts.get_by(email: email) do
      conn
      |> put_status(:ok)
      |> verify_user(%{user | password: password})
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
            |> resp(404, Poison.encode!(%{message: "This user does not exist or has already been deleted", response_code: :does_not_exist}))
            |> send_resp()
            |> halt()

    end
  end

  @spec verify_user(conn :: Plug.Conn.t(), user :: User.t()) :: Plug.Conn.t()
  defp verify_user(conn, %User{id: id} = user) do
    with {:ok, _reply} <- Accounts.authenticate_user(user),
         conn <- AttoLink.Auth.Guardian.Plug.sign_in(conn, user),
         {:ok, _permissions} <- AttoLink.Security.create_permissions(%{user_id: id}),
         token <- AttoLink.Auth.Guardian.Plug.current_token(conn) do
      conn
      |> put_status(:created)
      |> put_view(AttoLinkWeb.UserView)
      |> render(:login, user: user, token: token)
    else
      err ->
        err
    end
  end
end
