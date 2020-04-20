defmodule AttoLink.Repo.Migrations.AddPlanColumn do
  use Ecto.Migration

  def up do
    Plan.create_type()

    alter table(:user) do
      add :plan, Plan.type(), default: "free"
    end
  end

  def down do
    alter table(:user) do
      remove :plan
    end
    Plan.drop_type()
  end
end
