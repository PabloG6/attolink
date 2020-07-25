defmodule AttoLink.SecurityTest do
  use AttoLink.DataCase

  alias AttoLink.Security

  describe "permissions" do
    alias AttoLink.Security.Permissions

    @valid_attrs %{enable_whitelist: :all}
    @update_attrs %{enable_whitelist: :restricted}
    @invalid_attrs %{enable_whitelist: :unknown_param}

    def permissions_fixture(attrs \\ %{}) do
      {:ok, user} =
        AttoLink.Accounts.create_user(%{email: "random@email.com", password: "radsfjal", customer_id: "customer id"})

      {:ok, permissions} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{user_id: user.id})
        |> Security.create_permissions()

      permissions
    end

    test "list_permissions/0 returns all permissions" do
      permissions = permissions_fixture()
      assert Security.list_permissions() == [permissions]
    end

    test "get_permissions!/1 returns the permissions with given id" do
      permissions = permissions_fixture()
      assert Security.get_permissions!(permissions.id) == permissions
    end

    test "create_permissions/1 with valid data creates a permissions" do
      {:ok, user} =
        AttoLink.Accounts.create_user(%{
          email: "fsdaflk@email.com",
          password: "salfjroiedfaslrkeicmgres",
          customer_id: "customer id"
        })

      assert {:ok, %Permissions{} = permissions} =
               Security.create_permissions(@valid_attrs |> Enum.into(%{user_id: user.id}))
    end

    test "create_permissions/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Security.create_permissions(@invalid_attrs)
    end

    test "update_permissions/2 with valid data updates the permissions" do
      permissions = permissions_fixture()

      assert {:ok, %Permissions{} = permissions} =
               Security.update_permissions(permissions, @update_attrs)
    end

    test "update_permissions/2 with invalid data returns error changeset" do
      permissions = permissions_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Security.update_permissions(permissions, @invalid_attrs)

      assert permissions == Security.get_permissions!(permissions.id)
    end

    test "delete_permissions/1 deletes the permissions" do
      permissions = permissions_fixture()
      assert {:ok, %Permissions{}} = Security.delete_permissions(permissions)
      assert_raise Ecto.NoResultsError, fn -> Security.get_permissions!(permissions.id) end
    end

    test "change_permissions/1 returns a permissions changeset" do
      permissions = permissions_fixture()
      assert %Ecto.Changeset{} = Security.change_permissions(permissions)
    end
  end
end
