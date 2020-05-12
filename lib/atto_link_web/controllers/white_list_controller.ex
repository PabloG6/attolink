defmodule AttoLinkWeb.WhiteListController do
  use AttoLinkWeb, :controller

  alias AttoLink.Accounts
  alias AttoLink.Accounts.{WhiteList, User}

  action_fallback AttoLinkWeb.FallbackController

  def index(conn, _params) do
    %User{} = user = AttoLink.Auth.Guardian.Plug.current_resource(conn)
    whitelist = Accounts.list_whitelist(user)
    render(conn, "index.json", whitelist: whitelist)
  end

  def create(conn, %{"white_list" => white_list_params}) do
    user = AttoLink.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, %WhiteList{} = white_list} <-
           Accounts.create_white_list(white_list_params |> Enum.into(%{"user_id" => user.id})) do
      conn
      |> put_status(:created)
      |> render("show.json", white_list: white_list)
    end
  end

  def show(conn, %{"id" => id}) do
    white_list = Accounts.get_white_list!(id)
    render(conn, "show.json", white_list: white_list)
  end

  def update(conn, %{"id" => id, "white_list" => white_list_params}) do
    white_list = Accounts.get_white_list!(id)

    with {:ok, %WhiteList{} = white_list} <-
           Accounts.update_white_list(white_list, white_list_params) do
      render(conn, "show.json", white_list: white_list)
    end
  end

  def delete(conn, %{"id" => id}) do
    white_list = Accounts.get_white_list!(id)

    with {:ok, %WhiteList{}} <- Accounts.delete_white_list(white_list) do
      send_resp(conn, :no_content, "")
    end
  end
end
