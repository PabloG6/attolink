defmodule AttoLinkWeb.ApiController do
  use AttoLinkWeb, :controller

  alias AttoLink.Accounts
  alias AttoLink.Accounts.Api

  action_fallback AttoLinkWeb.FallbackController

  def index(conn, _params) do
    api_key = Accounts.list_api_key()
    render(conn, "index.json", api_key: api_key)
  end

  def create(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Api{} = api} <- Accounts.create_api(%{user_id: user.id}) do
      conn
      |> put_status(:created)
      |> put_resp_header("content-type", "application/json")
      |> render("show.json", api: api)
    end
  end

  def show(conn, %{"id" => id}) do
    api = Accounts.get_api(id)

    conn
    |> put_status(:ok)
    |> put_resp_header("content-type", "application/json")
    |> render(:show, api: api)
  end

  def delete(conn, %{"id" => id}) do
    api = Accounts.get_api!(id)

    with {:ok, %Api{}} <- Accounts.delete_api(api) do
      send_resp(conn, :no_content, "")
    end
  end
end
