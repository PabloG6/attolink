defmodule AttoLinkWeb.SubscriptionController do
  use AttoLinkWeb, :controller

  action_fallback AttoLinkWeb.FallbackController
  alias AttoLink.Accounts
  alias AttoLink.Payments

  def index(conn, _params) do
    plans = Payments.list_plans()

    conn
    |> put_status(:ok)
    |> put_view(AttoLinkWeb.SubscriptionsView)
    |> render(:plans, plans: plans)
  end

  def create(conn, %{
        "subscriptions" =>
          %{"payment_method_id" => pm_id, "plan_id" => plan_id} = _subscriptions_params
      }) do
    with %Accounts.User{email: email} = user <-
           AttoLink.Auth.Guardian.Plug.current_resource(conn),
         {:ok, %Stripe.Customer{id: cus_id} = customer} <-
           Stripe.Customer.create(%{
             email: email,
             payment_method: pm_id,
             invoice_settings: %{custom_fields: nil, default_payment_method: pm_id, footer: nil}
           }),
         {:ok, %Stripe.Subscription{id: sub_id} = _subscription} <-
           Stripe.Subscription.create(%{
             customer: customer,
             items: [%{plan: plan_id}]
           }),
           {:ok, %Payments.Subscription{nickname: nickname} = subscription} <-
            Payments.create_subscription(%{
              subscription_id: sub_id,
              user_id: user.id,
              plan_id: plan_id,
              customer_id: cus_id
            }),
         {:ok, %Stripe.Price{id: plan_id}} <- Stripe.Price.retrieve(plan_id),
         {:ok, %Accounts.User{}} <-
           Accounts.update_user_plan(user, %{
             customer_id: cus_id,
             nickname: nickname,
             }) do
      conn
      |> put_status(:created)
      |> put_view(AttoLinkWeb.SubscriptionsView)
      |> render("show.json", subscriptions: subscription)
    end
  end

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show(conn, _params) do
    user = AttoLink.Auth.Guardian.Plug.current_resource(conn)
    subscriptions = Payments.get_subscriptions_by(user_id: user.id)
    render(conn, "show.json", subscriptions: subscriptions)
  end

  def update(conn, %{"subscriptions" => %{"plan_id" => plan_id} = _subscriptions_params}) do
    user = AttoLink.Auth.Guardian.Plug.current_resource(conn)

    with %Payments.Subscription{subscription_id: subscription_id} = payments <-
           Payments.get_subscriptions_by(user_id: user.id),
         {:ok, %Stripe.Subscription{id: subscription_id, items: %Stripe.List{data: [sub_item | _]}}} <-
           Stripe.Subscription.retrieve(subscription_id),
         {:ok, %Stripe.Subscription{id: sub_id, items: %Stripe.List{data: [sub_item | _tail]}}} <-
           Stripe.Subscription.update(subscription_id, %{
             cancel_at_period_end: false,
             items: [%{id: sub_item.id, plan: plan_id}]
           }),
         {:ok, %Payments.Subscription{} = updated_payments} <-
           Payments.update_subscription(payments, %{
             subscription_id: sub_id,
             plan_id: plan_id
           }) do
      conn
      |> put_status(:ok)
      |> put_view(AttoLinkWeb.SubscriptionsView)
      |> render("show.json", subscriptions: updated_payments)
    else
      error ->

        error
    end
  end

  @spec delete(Plug.Conn.t(), any) :: any
  def delete(conn, _params) do
    user = AttoLink.Auth.Guardian.Plug.current_resource(conn)
    subscriptions = Payments.get_subscriptions_by(user_id: user.id)

    with {:ok, %Stripe.Subscription{} = _stripe_sub} <-
           Stripe.Subscription.update(subscriptions.subscription_id, %{cancel_at_period_end: true}),
         {:ok, %Payments.Subscription{}} <-
           Payments.update_subscription(subscriptions, %{canceled: true, nickname: "Free"}) do
      send_resp(conn, :no_content, "")
    end
  end



end
