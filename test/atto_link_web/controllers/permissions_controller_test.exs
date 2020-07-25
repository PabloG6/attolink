defmodule AttoLinkWeb.PermissionsControllerTest do
  use AttoLinkWeb.ConnCase

  alias AttoLink.Security
  alias AttoLink.Security.Permissions

  @create_attrs %{enable_whitelist: :all}
  @update_attrs %{enable_whitelist: :restricted}
  @invalid_attrs %{enable_whitelist: :disable_everything}
  @user_attrs %{email: "some@email.com", password: "sfjaklf", customer_id: "customer id"}

  def fixture(user_id) do
    {:ok, permissions} =
      Security.create_permissions(@create_attrs |> Enum.into(%{user_id: user_id}))

    permissions
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end



  describe "create permissions" do
    setup [:create_user, :sign_in_user]

    test "renders permissions when data is valid", %{conn: conn} do
      conn = post(conn, Routes.permissions_path(conn, :create), permissions: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.permissions_path(conn, :show))

      assert %{
               "id" => id,
               "enable_whitelist" => enable_whitelist
             } = json_response(conn, 200)["data"]

      assert enable_whitelist == "all"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.permissions_path(conn, :create, permissions: @invalid_attrs))

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update permissions" do
    setup [:create_user, :sign_in_user, :create_permissions]

    test "renders permissions when data is valid", %{
      conn: conn,
      permissions: %Permissions{id: id} = _permissions
    } do
      conn =
        put(conn, Routes.permissions_path(conn, :update), permissions: @update_attrs)

      assert %{"id" => ^id, "enable_whitelist" => "restricted"} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.permissions_path(conn, :show))

      assert %{
               "id" => id,
               "enable_whitelist" => "restricted"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, permissions: %Permissions{id: id}} do
      conn =
        put(conn, Routes.permissions_path(conn, :update, id: id),
          permissions: @invalid_attrs |> Enum.into(%{enable_whitelist: :anything})
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete permissions" do
    setup [:create_user, :sign_in_user, :create_permissions]
    @tag delete_permissions: true
    test "deletes chosen permissions", %{conn: conn, permissions: %Permissions{id: id} = _permissions} do
      conn = delete(conn, Routes.permissions_path(conn, :delete, id))
      assert response(conn, 204)

      conn = get(conn, Routes.permissions_path(conn, :show))
      assert json_response(conn, 404)
    end
  end

  describe "show permissions" do
    setup [:create_user, :sign_in_user, :create_permissions]

    test "display selected permissions", %{
      conn: conn,
      permissions: %Permissions{id: id} = _permissions
    } do
      conn = get(conn, Routes.permissions_path(conn, :show, id: id))

      assert %{
               "id" => ^id,
               "enable_whitelist" => enable_whitelist
             } = json_response(conn, 200)["data"]
    end
  end

  defp create_user(_) do
    {:ok, user} = AttoLink.Accounts.create_user(@user_attrs)
    {:ok, user: user}
  end

  defp sign_in_user(%{conn: conn, user: user}) do
    {:ok, token, _claims} = AttoLink.Auth.Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "bearer: " <> token)
    {:ok, user: user, conn: conn}
  end

  defp create_permissions(%{user: user}) do
    permissions = fixture(user.id)
    {:ok, permissions: permissions}
  end
end
