defmodule AttoLinkWeb.PasswordControllerTest do
  use AttoLinkWeb.ConnCase


  @create_attrs %{
    email: "testemail@website.com",
  }


  @invalid_attrs %{email: "noexists@email.com", password: "test_password"}
  @user_attrs %{email: "testemail@website.com", password: "test_password"}


  def fixture(_user) do
    {:ok, user} = AttoLink.Accounts.create_user(@user_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end



  describe "send reset password email" do
    setup [:create_user]
    test "create password reset request ticket when email exists", %{conn: conn} do
      conn = post(conn, Routes.password_path(conn, :send_email), password: @create_attrs)
      assert %{"message" => message, "code" => "password_reset_sent"} = json_response(conn, 200)["data"]


    end

    test "return an error stating no such email exists", %{conn: conn} do
      conn = post(conn, Routes.password_path(conn, :send_email),  password: @invalid_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end

    test "send an email twice to check if the password reset gets overriden", %{conn: conn} do
      conn = post(conn, Routes.password_path(conn, :send_email),  password: @create_attrs)
      assert json_response(conn, 200)

      conn = post(recycle(conn), Routes.password_path(conn, :send_email),  password: @create_attrs)
      assert json_response(conn, 200)
    end
  end



  defp create_password(_) do
    password = fixture(:password)
    {:ok, password: password}
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
