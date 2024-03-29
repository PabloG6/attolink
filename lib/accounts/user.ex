# Enum to determine the users subscription type.
import EctoEnum

defenum(
  Plan,
  :plan,
  [:free, :basic, :premium, :enterprise]
)

defmodule AttoLink.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias AttoLink.Accounts
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "user" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :plan, Plan, default: :free
    field :customer_id, :string
    has_many :api_keys, Accounts.Api
    has_many :previews, AttoLink.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :plan, :customer_id])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> put_password_hash
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: nil}} = changeset) do
    changeset
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, %{password_hash: Bcrypt.hash_pwd_salt(password)})
  end

  defp put_password_hash(changeset) do
    changeset
  end
end
