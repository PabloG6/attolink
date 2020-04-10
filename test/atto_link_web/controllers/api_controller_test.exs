defmodule AttoLinkWeb.ApiControllerTest do
  use AttoLinkWeb.ConnCase
  alias AttoLink.Accounts

  def fixture(%Accounts.User{id: id}) do
    {:ok, api} = Accounts.create_api(%{user_id: id})
    api
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_user, :sign_in_user]

    test "lists all api_key", %{conn: conn} do
      conn = get(conn, Routes.api_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create api when user is unauthorized" do
    setup [:create_user, :sign_in_user]

    test "renders api when data is valid", %{conn: conn, user: _user} do
      conn = post(conn, Routes.api_path(conn, :create))

      assert %{"id" => id, "user_id" => user_id, "api_key" => api_key} =
               json_response(conn, 201)["data"]

      conn = get(conn, Routes.api_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end
  end

  describe "create api" do
    setup [:create_user, :create_api]

    test "renders errors when user is not logged in", %{conn: conn} do
      conn = post(conn, Routes.api_path(conn, :create))
      assert json_response(conn, 401) != %{message: "authenticated"}
    end
  end

  describe "delete api" do
    setup [:create_user, :sign_in_user, :create_api]

    test "deletes chosen api", %{conn: conn, api: api} do
      conn = delete(conn, Routes.api_path(conn, :delete, api))
      assert response(conn, 204)

      assert nil == Accounts.get_api(api.id)
    end
  end

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(%{email: "some email", password: "some password"})
    {:ok, user: user}
  end

  defp create_api(%{conn: conn, user: user}) do
    api = fixture(user)
    {:ok, api: api, conn: conn}
  end

  defp sign_in_user(%{conn: conn, user: user}) do
    {:ok, token, _} = AttoLink.Auth.Guardian.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("authorization", "bearer: " <> token)
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn, user: user}
  end
end
