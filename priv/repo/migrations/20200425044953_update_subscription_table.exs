defmodule AttoLink.Repo.Migrations.UpdateSubscriptionTable do
  use Ecto.Migration

  def up do
    alter table(:subscription) do
      add :nickname, :string
    end
  end
end
