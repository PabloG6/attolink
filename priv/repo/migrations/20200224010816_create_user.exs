defmodule AttoLink.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user, primary_key: false) do
      add :email, :string
      add :password_hash, :string
      add :id, :binary_id, primary_key: true
      timestamps()
    end
  end
end
