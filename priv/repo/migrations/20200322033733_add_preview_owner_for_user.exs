defmodule AttoLink.Repo.Migrations.AddPreviewOwnerForUser do
  use Ecto.Migration

  def change do
    alter table(:preview) do
      add :user_id, references(:user, type: :uuid)
    end
  end
end
