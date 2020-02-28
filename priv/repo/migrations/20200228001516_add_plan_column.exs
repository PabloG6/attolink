defmodule AttoLink.Repo.Migrations.AddPlanColumn do
  use Ecto.Migration

  def up do
    Plan.create_type()
    alter table(:user) do
      add :plan, Plan.type(), default: "free"

    end
  end

  def down do
    Plan.drop_type()
  end
end

