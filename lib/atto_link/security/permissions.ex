import EctoEnum

defenum(WhiteListPermissions,
      :enable_white_list,
      [:all, :restricted, :none])


defmodule AttoLink.Security.Permissions do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :enable_whitelist, WhiteListPermissions, default: :all
    belongs_to :user, AttoLink.Accounts.User, type: :binary_id
    timestamps()
  end

  @doc false
  def changeset(permissions, attrs) do
    permissions
    |> cast(attrs, [:enable_whitelist, :user_id])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id)
  end
end
