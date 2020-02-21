defmodule AttoLink.Atto.Preview do
  use Ecto.Schema
  import Ecto.Changeset
  import LinkPreview

  schema "preview" do
    field :description, :string
    field :images, {:array, :map}
    field :original_url, :string
    field :title, :string
    field :website_url, :string

    timestamps()
  end

  @doc false
  def changeset(preview, attrs \\ %{}) do
    preview
    |> cast(attrs, [:description, :images, :original_url, :title, :website_url])
    |> validate_required([:website_url, :original_url])
  end
end
