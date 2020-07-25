defmodule AttoLink.AuthTest do
  use AttoLink.DataCase

  alias AttoLink.Auth

  describe "password_reset" do
    alias AttoLink.Auth.PasswordReset

    @user_attrs %{email: "email@email.com", password: "test_password", customer_id: "random_customer_id"}

    def password_fixture(%AttoLink.Accounts.User{} = user) do
      {:ok, password}
          = Auth.create_password_reset(%{user: user})
      password
    end

    def user_fixture() do
      {:ok, user} = AttoLink.Accounts.create_user(@user_attrs)
      user
    end

    test "create_password_reset/1 with valid data creates a password reset entry" do
      user = user_fixture()
      assert {:ok, %PasswordReset{} = password} = Auth.create_password_reset(%{user: user})

    end

    test "create_password_reset/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_password_reset(%{user: nil})
    end

    test "confirm_password_reset/1 updates passsword reset entry when user is successful" do
      user = user_fixture()
      password = password_fixture(user)
      assert {:ok, %PasswordReset{} = password} = Auth.confirm_password_reset(password)
    end


    test "send_password_reset_email/1 sends a dummy email whenever the user requests a password reset" do
      %AttoLink.Accounts.User{email: email} = user = user_fixture()
      %PasswordReset{id: id} = password_fixture(user)
      assert :ok = Auth.send_password_reset_email(email: email, id: id)
    end





  end
end
