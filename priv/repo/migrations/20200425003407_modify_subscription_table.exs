defmodule AttoLink.Repo.Migrations.AddSubscriptionCustomerIdAndUpdateSubscriptionId do
  use Ecto.Migration

  def up do
    alter table(:subscription) do
      add_if_not_exists(:customer_id, :string)
      remove_if_exists(:id, :bigserial)
      add :id, :binary_id
    end
  end

  def down do
    alter table(:subscription) do
      remove_if_exists(:id, :bigserial)
    end
  end
end
