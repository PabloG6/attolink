defmodule AttoLinkWeb.UserController do
  use AttoLinkWeb, :controller

  alias AttoLink.Accounts
  alias AttoLink.Accounts.User

  action_fallback AttoLinkWeb.FallbackController

  def index(conn, _params) do
    user = Accounts.list_user()
    render(conn, "index.json", user: user)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> signup_reply(user)
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

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  @spec signup_reply(Plug.Conn.t(), User.t()) :: Plug.Conn.t()
  defp signup_reply(conn, user = %User{}) do
    with {:ok, _reply} <- Accounts.authenticate_user(user),
         conn <- AttoLink.Auth.Guardian.Plug.sign_in(conn, user),
         token <- AttoLink.Auth.Guardian.Plug.current_token(conn) do
      conn
      |> put_status(:created)
      |> put_view(AttoLinkWeb.UserView)
      |> render(:login, user: user, token: token)
    end
  end
end
