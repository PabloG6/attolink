defmodule AttoLink.Repo.Migrations.ModifyPreviewColumns do
  use Ecto.Migration

  def change do
    rename table(:preview), :url, to: :images
  end
end
