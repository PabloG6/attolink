defmodule AttoLink.Auth.PasswordReset do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "password_reset" do
    field :is_reset, :boolean, default: false
    belongs_to :user, AttoLink.Accounts.User, type: :binary_id
    timestamps()
  end

  @doc false
  def changeset(password, %{user: user} = attrs) do
    password
    |> cast(attrs, [:is_reset])
    |> put_assoc(:user, user)
    |> validate_required([:user, :is_reset])
  end

  def confirm_password_reset_changeset(password) do
    password
    |> cast(%{is_reset: true}, [:is_reset])
    |> validate_required([:is_reset])

  end
end
