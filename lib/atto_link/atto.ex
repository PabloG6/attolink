defmodule AttoLink.Atto do
  @moduledoc """
  The Atto context.
  """

  import Ecto.Query, warn: false
  alias AttoLink.Repo
  alias LinkPreview
  alias AttoLink.Atto.Preview

  @doc """
  Returns the list of preview.

  ## Examples

      iex> list_preview()
      [%Preview{}, ...]

  """
  def list_preview do
    Repo.all(Preview)
  end

  @doc """
  Gets a single preview.

  Raises `Ecto.NoResultsError` if the Preview does not exist.

  ## Examples

      iex> get_preview!(123)
      %Preview{}

      iex> get_preview!(456)
      ** (Ecto.NoResultsError)

  """
  def get_preview!(url) do
    Repo.get_by!(Preview, url: url)
  end

  def get_preview(url) do
    Repo.get_by(Preview, url: url)
  end

  @doc """
  Creates a preview.

  ## Examples

      iex> create_preview(%{field: value})
      {:ok, %Preview{}}

      iex> create_preview(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_preview(url) do
    IO.puts url
    preview = LinkPreview.create(url)
    preview
  end

  @todo "0.0.1": "Save html page instead/save html page too"
  @todo "add @spec and @moduledoc"
  def cache_preview(attrs \\ %LinkPreview.Page{} = %LinkPreview.Page{}) do
    Preview.changeset(%Preview{}, Map.from_struct(attrs)) |> Repo.insert()
  end

  @doc """
  Updates a preview.

  ## Examples

      iex> update_preview(preview, %{field: new_value})
      {:ok, %Preview{}}

      iex> update_preview(preview, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_preview(%Preview{} = preview, attrs) do
    preview
    |> Preview.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a preview.

  ## Examples

      iex> delete_preview(preview)
      {:ok, %Preview{}}

      iex> delete_preview(preview)
      {:error, %Ecto.Changeset{}}

  """
  def delete_preview(%Preview{} = preview) do
    Repo.delete(preview)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking preview changes.

  ## Examples

      iex> change_preview(preview)
      %Ecto.Changeset{source: %Preview{}}

  """
  def change_preview(%Preview{} = preview) do
    Preview.changeset(preview, %{})
  end
end
