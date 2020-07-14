defmodule AttoLink.Comms.ConfirmEmail do
  use Ecto.Schema
  import Ecto.Changeset
  alias AttoLink.Accounts.User
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "confirm_email" do
    field :is_confirmed, :boolean, default: false
    field :email, :string
    belongs_to :user, User, type: :binary_id
    timestamps()
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:is_confirmed, :email])
    |> put_assoc(:user, attrs.user)
    |> put_email(attrs.user)
    |> validate_required([:is_confirmed, :user, :email])
    |> unique_constraint(:email, name: :email_user_index)
  end

  def update_confirm_changeset(email) do
    email
    |> cast(%{is_confirmed: true}, [:is_confirmed, :email])
    |> validate_required([:is_confirmed])
  end

  defp put_email(%Ecto.Changeset{valid?: true} = changeset, nil), do: changeset

  defp put_email(%Ecto.Changeset{valid?: true} = changeset, user) do

    changeset = change(changeset, %{email: user.email})

    changeset
  end

  defp put_email(changeset, _user) do
    changeset
  end
end
