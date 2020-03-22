defmodule AttoLink.Atto.Preview do
  use Ecto.Schema
  import Ecto.Changeset

  schema "preview" do
    field :description, :string
    field :images, {:array, :map}
    field :original_url, :string
    field :title, :string
    field :path, :string
    field :website_url, :string
    field :byte_size, :integer, default: 0
    belongs_to :user, AttoLink.Accounts.User, type: :binary_id
    timestamps()
  end

  @doc false
  def changeset(preview, attrs \\ %{}) do
    preview
    |> cast(attrs, [:description, :images, :original_url, :title, :website_url, :path, :byte_size])
    |> validate_required([:website_url, :original_url])
  end
end
