defmodule AttoLink.Accounts.Api do
  use Ecto.Schema
  import Ecto.Changeset
  alias AttoLink.Accounts

  schema "api_key" do
    belongs_to :user, Accounts.User, type: :binary_id
    field :api_key, :string
    timestamps()
  end

  @doc false
  def changeset(api, attrs) do
    api
    |> cast(attrs, [:user_id])
    |> generate_api_key
    |> validate_required([:user_id, :api_key])
    |> unique_constraint(:api_key)
  end

  defp generate_api_key(%Ecto.Changeset{valid?: true} = changeset) do
    put_change(changeset, :api_key, SecureRandom.uuid())
  end
end
