defmodule AttoLinkWeb.SubscriptionController do
  use AttoLinkWeb, :controller

  action_fallback AttoLinkWeb.FallbackController

  def index(_conn, _params) do
    # subscriptions = Payments.list_subscriptions()
    # render(conn, "index.json", subscriptions: subscriptions)
  end

  def create(_conn, %{"subscriptions" => _subscriptions_params}) do
  end

  def show(_conn, %{"id" => _id}) do
    # subscriptions = Payments.get_subscriptions!(id)
    # render(conn, "show.json", subscriptions: subscriptions)
  end

  def update(_conn, %{"id" => _id, "subscriptions" => _subscriptions_params}) do
    # subscriptions = Payments.get_subscriptions!(id)

    # with {:ok, %Subscriptions{} = subscriptions} <- Payments.update_subscriptions(subscriptions, subscriptions_params) do
    #   # render(conn, "show.json", subscriptions: subscriptions)
    # end
  end

  def delete(_conn, %{"id" => _id}) do
    # subscriptions = Payments.get_subscriptions!(id)

    # with {:ok, %Subscriptions{}} <- Payments.delete_subscriptions(subscriptions) do
    #   send_resp(conn, :no_content, "")
    # end
  end
end
