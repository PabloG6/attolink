defmodule AttoLink.Repo.Migrations.AddTypeToWhitelist do
  use Ecto.Migration

  def up do
    OriginType.create_type()
    alter table(:whitelist) do
      add :type, OriginType.type()
    end
  end

  def down do
    alter table(:whitelist) do
      remove :type
    end
    OriginType.drop_type()
  end
end
