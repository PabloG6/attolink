defmodule AttoLink.Repo.Migrations.AddCustomerId do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :customer_id, :text, null: true
    end
  end
end
