defmodule AttoLinkWeb.UserControllerTest do
  use AttoLinkWeb.ConnCase

  alias AttoLink.Accounts
  alias AttoLink.Accounts.User

  @create_attrs %{
    email: "some email",
    password: "some password_hash"
  }
  @update_attrs %{
    email: "some updated email",
    password: "some updated password_hash"
  }
  @invalid_attrs %{email: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_user, :sign_in_user]

    test "lists all user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200)["data"] == %{"email" => user.email, "id" => user.id}
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id, "email" => email, "token" => token} = json_response(conn, 201)["data"]
      conn = build_conn() |> put_req_header("authorization", "bearer: " <> token)
      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some email"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user, :sign_in_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some updated email"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user, :sign_in_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp sign_in_user(%{conn: conn, user: user}) do
    {:ok, token, _claims} = AttoLink.Auth.Guardian.encode_and_sign(user)
    conn = conn |> put_req_header("authorization", "bearer: " <> token)
    {:ok, user: user, conn: conn}
  end
end
