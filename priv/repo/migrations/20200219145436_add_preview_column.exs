defmodule AttoLink.Repo.Migrations.AddPreviewColumn do
  use Ecto.Migration

  def change do
    alter table(:preview) do
      add :description, :string
      add :website_url, :string
      add :url, {:array, :map}
      add :title, :string
      add :original_url, :string
    end
  end
end
