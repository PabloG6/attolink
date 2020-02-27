defmodule AttoLink.AccountsTest do
  use AttoLink.DataCase

  alias AttoLink.Accounts

  describe "user" do
    alias AttoLink.Accounts.User

    @valid_attrs %{email: "some email", password: "some password_hash"}
    @update_attrs %{email: "some updated email", password: "some updated password_hash"}
    @invalid_attrs %{email: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_user/0 returns all user" do
      user = user_fixture()
      assert Accounts.list_user() == [%{user | password: nil}]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      user_check = Accounts.get_user!(user.id)
      assert user.id == user_check.id
      assert user.email == user_check.email
      assert Bcrypt.verify_pass("some password_hash", user.password_hash)
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert Bcrypt.verify_pass("some password_hash", user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert Bcrypt.verify_pass("some updated password_hash", user.password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert %{user | password: nil} == %{Accounts.get_user!(user.id) | password: nil}
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "api_key" do
    alias AttoLink.Accounts.Api

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def api_fixture(attrs \\ %{}) do
      {:ok, user} = Accounts.create_user(%{email: "some email", password: "password"})
      lol = %{user_id: user.id} |> Enum.into(@valid_attrs)

      {:ok, api} =
        lol
        |> Enum.into(@valid_attrs)
        |> Accounts.create_api()

      api
    end

    test "list_api_key/0 returns all api_key" do
      api = api_fixture()
      assert Accounts.list_api_key() == [api]
    end

    test "get_api!/1 returns the api with given id" do
      api = api_fixture()
      assert Accounts.get_api!(api.id) == api
    end

    test "create_api/1 with valid data creates a api" do
      {:ok, user} = Accounts.create_user(%{email: "some email", password: "some password"})
      assert {:ok, %Api{} = api} = Accounts.create_api(%{user_id: user.id})
    end

    test "create_api/1 with invalid data returns error changeset" do
      {:ok, user} = Accounts.create_user(%{email: "some email", password: "some password"})
      assert {:error, %Ecto.Changeset{}} = Accounts.create_api(%{})
    end

    test "delete_api/1 deletes the api" do
      api = api_fixture()
      assert {:ok, %Api{}} = Accounts.delete_api(api)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_api!(api.id) end
    end
  end
end
