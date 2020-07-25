defmodule AttoLinkWeb.SubscriptionControllerTest do
  use AttoLinkWeb.ConnCase
  alias AttoLink.Accounts

  defp fixture() do
    with {:ok, %Accounts.User{} = user} <-
           Accounts.create_user(%{email: "some@email.com", password: "adfsfsakrjf", customer_id: "price_1H7wzpFiqLhwiC9fKHf53SoJ"}),
         {:ok, %Stripe.PaymentMethod{id: pm_id}} <-
           Stripe.PaymentMethod.create(%{
             type: "card",
             card: %{number: "4242424242424242", cvc: 421, exp_year: 2022, exp_month: 8}
           }) do
      {:ok, payment_method_id: pm_id, user: user}
    end
  end


  setup %{conn: conn} do
    {:ok, payment_method_id: payment_method_id, user: user} = fixture()
    {:ok, token, _claims} = AttoLink.Auth.Guardian.encode_and_sign(user)
    conn = conn |> put_req_header("authorization", "bearer: " <> token)

    {:ok,
     conn: conn |> put_req_header("accept", "application/json"),
     payment_method_id: payment_method_id,
     user: user}
  end

  describe "create a subscription" do
    test "create a subscription with valid user information", %{
      conn: conn,
      payment_method_id: payment_method_id,
      user: _user
    } do

      {:ok, basic} = Application.fetch_env(:atto_link, :basic)
      {:ok, %Stripe.Price{id: price_id}} = Stripe.Price.retrieve(basic)

      conn =
        post(
          conn,
          Routes.subscription_path(conn, :create,
            subscriptions: %{payment_method_id: payment_method_id, plan_id: price_id}
          )
        )

      assert json_response(conn, 201)
    end
  end

  describe "downgrade and upgrade your subscription" do
    test "upgrade subscription from your basic plan to your premium plan. ", %{
      conn: conn,
      payment_method_id: payment_method_id
    } do
      {:ok, price} = Application.fetch_env(:atto_link, :basic)
      {:ok, %Stripe.Price{id: plan_id}} = _plan = Stripe.Price.retrieve(price)

      conn =
        post(
          conn,
          Routes.subscription_path(conn, :create,
            subscriptions: %{payment_method_id: payment_method_id, plan_id: plan_id}
          )
        )

      assert json_response(conn, 201)
      {:ok, enterprise} = Application.fetch_env(:atto_link, :enterprise)
      {:ok, %Stripe.Price{id: enterprise_id}} = Stripe.Price.retrieve(enterprise)

      conn =
        put(
          conn,
          Routes.subscription_path(conn, :update, subscriptions: %{plan_id: enterprise_id})
        )

      assert json_response(conn, 200)
    end

    test "downgrade subscription from enterprise plan to basic plan. ", %{
      conn: conn,
      payment_method_id: payment_method_id
    } do
      {:ok, basic} = Application.fetch_env(:atto_link, :basic)
      {:ok, enterprise} = Application.fetch_env(:atto_link, :enterprise)
      {:ok, %Stripe.Price{id: enterprise_id}} = Stripe.Price.retrieve(enterprise)
      {:ok, %Stripe.Price{id: basic_plan}} = Stripe.Price.retrieve(enterprise)

      conn =
        post(
          conn,
          Routes.subscription_path(conn, :create,
            subscriptions: %{payment_method_id: payment_method_id, plan_id: enterprise_id}
          )
        )

      assert json_response(conn, 201)

      conn =
        put(conn, Routes.subscription_path(conn, :update, subscriptions: %{plan_id: basic_plan}))

      assert json_response(conn, 200)
    end
  end
end
