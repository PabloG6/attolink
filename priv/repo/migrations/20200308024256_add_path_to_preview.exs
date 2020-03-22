defmodule AttoLink.Repo.Migrations.AddPathToPreview do
  use Ecto.Migration

  def change do
    alter table(:preview) do
      add :path, :string
    end
  end
end
