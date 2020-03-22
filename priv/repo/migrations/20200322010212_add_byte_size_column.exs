defmodule AttoLink.Repo.Migrations.AddByteSizeColumn do
  use Ecto.Migration

  def change do
    alter table(:preview) do
      add :byte_size, :integer, default: 0
    end
  end
end
