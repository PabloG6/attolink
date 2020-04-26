defmodule AttoLink.Repo.Migrations.ModifySubscriptions do
  use Ecto.Migration

  def up do
    alter table(:subscription) do
      add :user_id, references(:user, type: :uuid, on_delete: :delete_all)
      add :plan_name, :string
      remove :canceled_at
    end
  end

  def down do
    alter table(:subscription) do
      remove :user_id
      remove :plan_name
    end
  end
end
