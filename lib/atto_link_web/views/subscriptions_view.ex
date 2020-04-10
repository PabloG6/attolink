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
      customer_id: subscriptions.customer_id,
      subscription_type: subscriptions.subscription_type
    }
  end
end
