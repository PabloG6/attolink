defmodule AttoLink.Repo.Migrations.CreateApiKey do
  use Ecto.Migration

  def change do
    create table(:api_key) do
      add :user_id, references(:user, type: :uuid)
      add :api_key, :string
      timestamps()
    end
  end
end
