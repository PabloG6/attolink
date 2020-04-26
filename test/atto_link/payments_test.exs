defmodule AttoLink.PaymentsTest do
  use AttoLink.DataCase

  alias AttoLink.Payments
  alias AttoLink.Accounts
  describe "subscription" do
    alias AttoLink.Payments.Subscription

    @valid_attrs %{
      canceled: true,
      customer_id: "some customer",
      nickname: "Free",
      subscription_id: "some subscription_id"
    }
    @update_attrs %{
      canceled: false,
      customer_id: "some updated customer",
      subscription_id: "some updated subscription_id"
    }
    @invalid_attrs %{canceled: nil, canceled_at: nil, customer: nil, subscription_id: nil}

    def subscription_fixture(attrs \\ %{}) do
      {:ok, user} = Accounts.create_user(%{email: "someemail@gmail.com", password: "password"})
      {:ok, subscription} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{user_id: user.id})
        |> Payments.create_subscription()

      subscription
    end

    test "list_subscription/0 returns all subscription" do
      subscription = subscription_fixture()
      assert Payments.list_subscription() == [subscription]
    end

    test "get_subscription!/1 returns the subscription with given id" do
      subscription = subscription_fixture()

      assert Payments.get_subscription!(subscription.id) == subscription
    end

    test "create_subscription/1 with valid data creates a subscription" do
      {:ok, %Accounts.User{id: id}} = Accounts.create_user(%{email: "grammy@email.com", password: "password"})
      assert {:ok, %Subscription{} = subscription} = Payments.create_subscription(@valid_attrs |> Enum.into(%{user_id: id}))
      assert subscription.canceled == true
      assert subscription.customer_id == "some customer"
      assert subscription.subscription_id == "some subscription_id"
    end

    test "create_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_subscription(@invalid_attrs)
    end

    test "update_subscription/2 with valid data updates the subscription" do
      subscription = subscription_fixture()

      assert {:ok, %Subscription{} = subscription} =
               Payments.update_subscription(subscription, @update_attrs)

      assert subscription.canceled == false
      assert subscription.customer_id == "some updated customer"
      assert subscription.subscription_id == "some updated subscription_id"
    end

    test "update_subscription/2 with invalid data returns error changeset" do
      subscription = subscription_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_subscription(subscription, @invalid_attrs)

      assert subscription == Payments.get_subscription!(subscription.id)
    end

    test "delete_subscription/1 deletes the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{}} = Payments.delete_subscription(subscription)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_subscription!(subscription.id) end
    end

    test "change_subscription/1 returns a subscription changeset" do
      subscription = subscription_fixture()
      assert %Ecto.Changeset{} = Payments.change_subscription(subscription)
    end
  end
end
