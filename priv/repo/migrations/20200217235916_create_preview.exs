defmodule AttoLink.Repo.Migrations.CreatePreview do
  use Ecto.Migration

  def change do
    create table(:preview) do
      timestamps()
    end
  end
end
