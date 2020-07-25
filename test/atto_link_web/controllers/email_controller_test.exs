defmodule AttoLinkWeb.EmailControllerTest do
  use AttoLinkWeb.ConnCase

  alias AttoLink.Comms

  @create_attrs %{
    email: "test@email.com",
  }

  @user_attrs %{email: "test@email.com", password: "password", customer: "random customer id"}


  def fixture(:email) do
    {:ok, email} = Comms.create_email(@create_attrs)
    email
  end

  def fixture(:user) do
    {:ok, user} = AttoLink.Accounts.create_user(@user_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "send confirmation email" do
    setup [:create_user]
    test "send an email because the email exists in the database ", %{conn: conn} do
      conn = post(conn, Routes.email_path(conn, :send_email, email: "test@email.com"))
      assert json_response(conn, 200)


    end

    test "return an error because the email doesn't exist in the database", %{conn: conn} do
      conn = post(conn, Routes.email_path(conn, :send_email), email: "noemail@email.com")
      assert %{"code" => "email_not_sent", "message" => message} = json_response(conn, 422)["errors"]
    end

    test "confirm the email exists when the user clicks on the link. ", %{conn: conn, user: user} do

      conn = post(conn, Routes.email_path(conn, :send_email), email: "test@email.com")
      user = AttoLink.Accounts.get_user(user.id) |> AttoLink.Repo.preload([:confirm_email])
      [head | _tail] = user.confirm_email

      conn = put(conn, Routes.email_path(conn, :confirm_email_address, head.id))
      assert json_response(conn, 200)

    end
  end



  defp create_email(_) do
    email = fixture(:email)
    {:ok, email: email}
  end

  defp create_user(_) do
    {:ok, user} = AttoLink.Accounts.create_user(%{email: "test@email.com", password: "some random password", customer_id: "some random customer"})
    {:ok, user: user}
  end
end
