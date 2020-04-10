defmodule AttoLink.Security do
  @moduledoc """
  The Security context.
  """

  import Ecto.Query, warn: false
  alias AttoLink.Repo

  alias AttoLink.Security.Permissions

  @doc """
  Returns the list of permissions.

  ## Examples

      iex> list_permissions()
      [%Permissions{}, ...]

  """
  def list_permissions do
    Repo.all(Permissions)
  end

  @doc """
  Gets a single permissions.

  Raises `Ecto.NoResultsError` if the Permissions does not exist.

  ## Examples

      iex> get_permissions!(123)
      %Permissions{}

      iex> get_permissions!(456)
      ** (Ecto.NoResultsError)

  """
  def get_permissions!(id), do: Repo.get!(Permissions, id)

  def get_permissions_by!(info \\ []) do
    with %Permissions{} = permissions <- Repo.get_by(Permissions, info) do
      {:ok, permissions}
    else
      nil ->
        {:error, :no_permissions}
    end
  end

  @doc """
  Creates a permissions.

  ## Examples

      iex> create_permissions(%{field: value})
      {:ok, %Permissions{}}

      iex> create_permissions(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_permissions(attrs \\ %{}) do
    %Permissions{}
    |> Permissions.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a permissions.

  ## Examples

      iex> update_permissions(permissions, %{field: new_value})
      {:ok, %Permissions{}}

      iex> update_permissions(permissions, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_permissions(%Permissions{} = permissions, attrs) do
    permissions
    |> Permissions.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a permissions.

  ## Examples

      iex> delete_permissions(permissions)
      {:ok, %Permissions{}}

      iex> delete_permissions(permissions)
      {:error, %Ecto.Changeset{}}

  """
  def delete_permissions(%Permissions{} = permissions) do
    Repo.delete(permissions)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking permissions changes.

  ## Examples

      iex> change_permissions(permissions)
      %Ecto.Changeset{source: %Permissions{}}

  """
  def change_permissions(%Permissions{} = permissions) do
    Permissions.changeset(permissions, %{})
  end
end
