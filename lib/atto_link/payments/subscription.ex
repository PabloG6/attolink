defmodule AttoLink.Payments.Subscription do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @plans %{
    "price_1H8H7KFiqLhwiC9fl9kxFrpW" => :free,
  "price_1H8H7KFiqLhwiC9fUtcdn0h4" => :basic,
  "price_1H8H7KFiqLhwiC9fx4UiekeA" => :premium,
  "price_1H8H7KFiqLhwiC9ffzPAIGcy" => :enterprise}
  schema "subscription" do
    field :canceled, :boolean, default: false
    field :customer_id, :string
    field :subscription_id, :string
    field :nickname, Plan, default: :free
    field :plan_id, :string
    belongs_to :user, AttoLink.Accounts.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do

    subscription
    |> cast(attrs, [:subscription_id, :customer_id, :canceled, :user_id, :plan_id])
    |> create_nickname
    |> validate_required([:canceled, :user_id, :nickname, :subscription_id, :plan_id])
  end



  defp create_nickname(%Ecto.Changeset{valid?: true, changes: %{plan_id: price_id}} = changeset) do
    change(changeset, %{nickname: @plans[price_id]})
  end
  defp create_nickname(%Ecto.Changeset{} = changeset), do: changeset


end
