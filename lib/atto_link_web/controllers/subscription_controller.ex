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
          %{"payment_method_id" => pm_id, "plan_id" => plan_id
          
          
          } = _subscriptions_params
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
         {:ok, %Stripe.Plan{nickname: nickname}} <- Stripe.Plan.retrieve(plan_id),
         {:ok, %Accounts.User{}} <-
           Accounts.update_user_plan(user, %{
             customer_id: cus_id,
             plan: String.downcase(nickname) |> convert_to_atom()
           }),
         {:ok, %Payments.Subscription{} = subscription} <-
           Payments.create_subscription(%{
             subscription_id: sub_id,
             user_id: user.id,
             nickname: nickname,
             customer_id: cus_id
           }) do
      conn
      |> put_status(:created)
      |> put_view(AttoLinkWeb.SubscriptionsView)
      |> render("show.json", subscriptions: subscription)
    end
  end


  def show(conn, _params) do
    user = AttoLink.Auth.Guardian.Plug.current_resource(conn)
    subscriptions = Payments.get_subscriptions_by(user_id: user.id)
    render(conn, "show.json", subscriptions: subscriptions)
  end

  def update(conn, %{"subscriptions" => %{"plan_id" => plan_id} = _subscriptions_params}) do
    user = AttoLink.Auth.Guardian.Plug.current_resource(conn)

    with %Payments.Subscription{subscription_id: subscription_id} = payments <-
           Payments.get_subscriptions_by(user_id: user.id),
         {:ok, %Stripe.Subscription{id: sub_id, items: %Stripe.List{data: items_list}}} <-
           Stripe.Subscription.retrieve(subscription_id),
         item <- Enum.at(items_list, 0),
         {:ok, %Stripe.Subscription{id: sub_id,items: %Stripe.List{data: [sub_item | _tail]}} = subscription} <- Stripe.Subscription.update(sub_id, %{
                                                                                  cancel_at_period_end: false,
                                                                                  items: [%{id: item.id, plan: plan_id}]
                                                                                }),
         {:ok, %Payments.Subscription{}} <- Payments.update_subscription(payments, %{subscription_id: sub_id, nickname: sub_item.plan.nickname,
                                            plan_id: plan_id})
          do

                conn
                |> put_status(:ok)
                |> put_view(AttoLinkWeb.SubscriptionsView)
                |> render("show.json", subscriptions: subscription)


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


  defp convert_to_atom(atom) do
    try do
      String.to_existing_atom(atom)
     rescue
      ArgumentError ->
          String.to_atom(atom)
    end
  end
end
