defmodule AttoLink.Payments.Subscription do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
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
    IO.inspect attrs
    subscription
    |> cast(attrs, [:subscription_id, :customer_id, :canceled, :nickname, :user_id, :plan_id])
    |> validate_required([:subscription_id, :canceled, :user_id, :nickname, :plan_id])
  end
end
