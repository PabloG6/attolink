defmodule AttoLink.Repo.Migrations.AddPlanIdToSubscription do
  use Ecto.Migration

  def up do
    alter table(:subscription) do
      add :plan_id, :string
    end

  end

  def down do
    alter table(:subscription) do
      remove :plan_id, :string
    end
  end
end
