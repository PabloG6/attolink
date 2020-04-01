defmodule AttoLink.Payments.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscription" do
    field :canceled, :boolean, default: false
    field :canceled_at, :integer
    field :customer, :string
    field :subscription_id, :string

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:subscription_id, :customer, :canceled, :canceled_at])
    |> validate_required([:subscription_id, :customer, :canceled, :canceled_at])
  end
end
