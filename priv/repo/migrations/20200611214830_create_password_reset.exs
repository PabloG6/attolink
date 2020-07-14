defmodule AttoLink.Repo.Migrations.CreatePasswordReset do
  use Ecto.Migration

  def change do
    create table(:password_reset, primary_key: false) do
      add :user_id, references(:user, type: :uuid, on_delete: :delete_all)
      add :is_reset, :boolean, default: false, null: false
      add :id, :binary_id, primary_key: true
      timestamps()
    end

    create unique_index(:password_reset, [:user_id])
  end
end
