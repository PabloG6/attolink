defmodule AttoLinkWeb.PermissionsController do
  use AttoLinkWeb, :controller
  import AttoLink.Repo, only: [preload: 2], warn: false
  alias AttoLink.Security
  alias AttoLink.Security.Permissions
  alias AttoLink.Auth
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

  def show(conn, _params) do
    user = Auth.Guardian.Plug.current_resource(conn) |> preload(:permissions)
    permissions = user.permissions

    if permissions == nil do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:not_found, Poison.encode!(%{message: "no permissions found"}))
    else
      render(conn, "show.json", permissions: permissions)
    end
  end

  def update(conn, %{"permissions" => permissions_params}) do
    %AttoLink.Accounts.User{id: id} = AttoLink.Auth.Guardian.Plug.current_resource(conn)
    case Security.get_permissions_by!(user_id: id) do
      {:ok, permissions} ->
        with {:ok, %Permissions{} = permissions} <-
          Security.update_permissions(
            permissions,
            permissions_params |> Enum.into(%{"user_id" => id})
          ) do
     render(conn, "show.json", permissions: permissions)
    end
      {:error, :no_permissions} ->
<<<<<<< HEAD
        {:ok, permissions} = Security.create_permissions(permissions_params |> Enum.into(%{"user_id" => id}))
        render(conn, "show.json", permissions: permissions)
=======
        Security.create_permissions(permissions_params |> Enum.into(%{"user_id" => id}))
>>>>>>> 791c7442c25876e32ef100d96b6272b502388f3b
    end

  end

  def delete(conn, %{"id" => id}) do
    permissions = Security.get_permissions!(id)

    with {:ok, %Permissions{}} <- Security.delete_permissions(permissions) do
      send_resp(conn, :no_content, "")
    end
  end
end
