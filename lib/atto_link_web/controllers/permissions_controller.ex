defmodule AttoLinkWeb.PermissionsController do
  use AttoLinkWeb, :controller

  alias AttoLink.Security
  alias AttoLink.Security.Permissions

  action_fallback AttoLinkWeb.FallbackController
  def index(conn, _params) do
    permissions = Security.list_permissions()
    render(conn, "index.json", permissions: permissions)
  end

  def create(conn, %{"permissions" => permissions_params}) do
    user = AttoLink.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, %Permissions{} = permissions} <-
           Security.create_permissions(permissions_params |> Enum.into(%{"user_id" => user.id})) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.permissions_path(conn, :show, permissions))
      |> render("show.json", permissions: permissions)
    else
      {:error, %Ecto.Changeset{errors: [user_id: _user_error]}} ->
        conn
        |> resp(
          409,
          Poison.encode!(%{
            message: "This user already has permissions set",
            response_code: :already_set_permissions
          })
        )
        |> send_resp()
        |> halt()

      error ->
        error
    end
  end

  def show(conn, %{"id" => id}) do
    permissions = Security.get_permissions!(id)
    render(conn, "show.json", permissions: permissions)
  end

  def update(conn, %{"permissions" => permissions_params}) do
    %AttoLink.Accounts.User{id: id} = AttoLink.Auth.Guardian.Plug.current_resource(conn)
    {:ok, permissions} = Security.get_permissions_by!(user_id: id)

    with {:ok, %Permissions{} = permissions} <-
           Security.update_permissions(
             permissions,
             permissions_params |> Enum.into(%{"user_id" => id})
           ) do
      render(conn, "show.json", permissions: permissions)
    end
  end

  def delete(conn, %{"id" => id}) do
    permissions = Security.get_permissions!(id)

    with {:ok, %Permissions{}} <- Security.delete_permissions(permissions) do
      send_resp(conn, :no_content, "")
    end
  end
end
