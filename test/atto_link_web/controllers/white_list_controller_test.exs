defmodule AttoLinkWeb.WhiteListControllerTest do
  use AttoLinkWeb.ConnCase

  alias AttoLink.Accounts
  alias AttoLink.Accounts.WhiteList

  @create_attrs %{
    ip_address: "some ip_address",

  }
  @update_attrs %{
    ip_address: "some updated ip_address"
  }
  @invalid_attrs %{ip_address: nil}

  def fixture(user_id) do
    {:ok, white_list} = Accounts.create_white_list(@create_attrs |> Enum.into(%{user_id: user_id}))
    white_list
  end

  setup %{conn: conn} do
    {:ok, user} = Accounts.create_user(%{email: "user@gmail.com", password: "password"})
    {:ok, token, _claims} = AttoLink.Auth.Guardian.encode_and_sign(user)
    conn = conn |> put_req_header("authorization", "bearer: " <> token)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user}
  end

  describe "index" do
    test "lists all whitelist", %{conn: conn} do
      conn = get(conn, Routes.white_list_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create white_list" do
    test "renders white_list when data is valid", %{conn: conn} do
      conn = post(conn, Routes.white_list_path(conn, :create), white_list: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.white_list_path(conn, :show, id))

      assert %{
               "id" => id,
               "ip_address" => "some ip_address"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.white_list_path(conn, :create), white_list: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update white_list" do
    setup [:create_white_list]

    test "renders white_list when data is valid", %{conn: conn, white_list: %WhiteList{id: id} = white_list} do
      conn = put(conn, Routes.white_list_path(conn, :update, white_list), white_list: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.white_list_path(conn, :show, id))

      assert %{
               "id" => id,
               "ip_address" => "some updated ip_address"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, white_list: white_list} do
      conn = put(conn, Routes.white_list_path(conn, :update, white_list), white_list: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete white_list" do
    setup [:create_white_list]

    test "deletes chosen white_list", %{conn: conn, white_list: white_list} do
      conn = delete(conn, Routes.white_list_path(conn, :delete, white_list))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.white_list_path(conn, :show, white_list))
      end
    end
  end

  defp create_white_list(%{conn: _conn, user: user}) do
    white_list = fixture(user.id)
    {:ok, white_list: white_list}
  end
end
