defmodule AttoLinkWeb.SubscriptionsView do
  use AttoLinkWeb, :view
  alias AttoLinkWeb.SubscriptionsView

  def render("index.json", %{subscriptions: subscriptions}) do
    %{data: render_many(subscriptions, SubscriptionsView, "subscriptions.json")}
  end

  def render("show.json", %{subscriptions: subscriptions}) do
    %{data: render_one(subscriptions, SubscriptionsView, "subscriptions.json")}
  end

  def render("subscriptions.json", %{subscriptions: subscriptions}) do

    %{
      id: subscriptions.id,
      nickname: subscriptions.nickname,
      sub_id: subscriptions.subscription_id
    }
  end

  def render("plans.json", %{plans: plans}) do
    %{data: render_many(plans, SubscriptionsView, "plan.json", as: :plan)}
  end

  def render("plan.json", %{
        plan: %Stripe.Plan{id: id, nickname: nickname, amount: amount, currency: currency}
      }) do
    %{
      id: id,
      nickname: nickname,
      amount: amount,
      currency: currency
    }
  end
end
