defmodule AttoLink.Repo.Migrations.CreateWhitelist do
  use Ecto.Migration

  def change do
    create table(:whitelist) do
      add :ip_address, :string
      add :user_id, references(:user, type: :uuid)
      timestamps()
    end

    create unique_index(:whitelist, [:user_id, :ip_address])

  end
end
