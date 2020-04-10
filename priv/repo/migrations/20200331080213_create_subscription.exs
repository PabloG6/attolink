defmodule AttoLink.Repo.Migrations.CreateSubscription do
  use Ecto.Migration

  def change do
    create table(:subscription) do
      add :subscription_id, :string
      add :customer, :string
      add :canceled, :boolean, default: false, null: false
      add :canceled_at, :integer

      timestamps()
    end
  end
end
