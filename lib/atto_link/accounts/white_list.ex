defmodule AttoLink.Accounts.WhiteList do
  use Ecto.Schema
  import Ecto.Changeset
  alias AttoLink.Accounts

  schema "whitelist" do
    field :ip_address, :string
    belongs_to :user, Accounts.User, type: :binary_id
    timestamps()
  end

  @doc false
  def changeset(white_list, attrs) do
    white_list
    |> cast(attrs, [:ip_address, :user_id])
    |> validate_required([:ip_address, :user_id])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:ip_address, name: :whitelist_ip_address_user_index)
  end
end
