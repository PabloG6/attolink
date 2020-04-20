defmodule AttoLink.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def up do
    WhiteListPermissions.create_type()

    create table(:permissions) do
      add :enable_whitelist, WhiteListPermissions.type(), default: "all"
      add :user_id, references(:user, type: :uuid, on_delete: :delete_all)
      timestamps()
    end

    unique_index(:permissions, :user_id)
  end

  def down do
    drop table(:permissions)
    WhiteListPermissions.drop_type()
  end
end
