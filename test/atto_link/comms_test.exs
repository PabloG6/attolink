defmodule AttoLink.CommsTest do
  use AttoLink.DataCase

  alias AttoLink.Comms

  describe "confirm_email" do
    alias AttoLink.Comms.ConfirmEmail


    @user_attrs %{email: "testemail@website.com", password: "test_password"}
    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@user_attrs)
        |> AttoLink.Accounts.create_user()
      user

    end
    def email_fixture(user) do

      {:ok, email} = Comms.create_email(%{user: user})

      email
    end


    test "get_email!/1 returns the email with given id" do
      user = user_fixture()
      email = email_fixture(user)
      assert  Comms.get_email!(email.id).id == email.id
    end

    test "create_email/1 with valid data creates a email" do
      user = user_fixture()

      assert {:ok, %ConfirmEmail{} = email} = Comms.create_email(%{user: user})
      assert email.is_confirmed == false
    end



    test "create_email/1 with invalid data returns error changeset" do

      assert {:error, %Ecto.Changeset{}} = Comms.create_email(%{user: nil})
    end

    test "confirm_email/1 with valid data returns confirm_email struct" do
      user = user_fixture()
      email = email_fixture(user)
      assert {:ok, %ConfirmEmail{}} = Comms.confirm_email(email)

    end

  end
end
