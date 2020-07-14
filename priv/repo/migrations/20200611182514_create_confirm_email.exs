defmodule AttoLink.Repo.Migrations.CreateConfirmEmail do
  use Ecto.Migration

  def change do
    create table(:confirm_email, primary_key: false) do
      add :user_id, references(:user, type: :uuid, on_delete: :delete_all)
      add :is_confirmed, :boolean, default: false, null: false
      add :email, :text, null: false
      add :id, :binary_id, primary_key: true
      timestamps()
    end

    create unique_index(:confirm_email, [:id, :user_id], name: :email_user_index)

  end
end
