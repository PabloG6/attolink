import EctoEnum

defenum(
  WhiteListPermissions,
  :enable_white_list,
  [:all, :restricted, :none]
)

defmodule AttoLink.Security.Permissions do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :enable_whitelist, WhiteListPermissions, default: :all
    belongs_to :user, AttoLink.Accounts.User, type: :binary_id
    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(permissions, attrs) do
    permissions
    |> cast(attrs, [:enable_whitelist, :user_id])
    |> validate_required([:user_id, :enable_whitelist])
    |> foreign_key_constraint(:user_id, name: :permissions_user_id_fkey)
    |> unique_constraint(:user_id)
  end
end
