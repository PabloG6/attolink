defmodule AttoLink.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias AttoLink.Repo
  import Bcrypt, only: [check_pass: 2]
  alias AttoLink.Accounts.User

  @doc """
  Returns the list of user.

  ## Examples

      iex> list_user()
      [%User{}, ...]

  """
  def list_user do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
    Gets a single user.
    returns nil if the user does not exist.

    ## Examples
    iex> get_user(123)
    %User{}

    iex> get_user(456)
    nil
  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def authenticate_user(%User{email: email, password: password}) do
    Repo.get_by(User, [email: email])
    |>check_pass(password)
  end


  alias AttoLink.Accounts.Api

  @doc """
  Returns the list of api_key.

  ## Examples

      iex> list_api_key()
      [%Api{}, ...]

  """
  def list_api_key do
    Repo.all(Api)
  end

  @doc """
  Gets a single api.

  Raises `Ecto.NoResultsError` if the Api does not exist.

  ## Examples

      iex> get_api!(123)
      %Api{}

      iex> get_api!(456)
      ** (Ecto.NoResultsError)

  """
  def get_api!(id), do: Repo.get!(Api, id)

  @doc """
  Get a single api.
  Returns nil if the Api does not exist.

  ## Examples
  iex> get_api(123)
  %Api{}

  iex> get_api(456)
  ** (Ecto.NoResultsError)

  """

  def get_api(id), do: Repo.get(Api, id)

  @doc """
  Creates a api.

  ## Examples

      iex> create_api(%{field: value})
      {:ok, %Api{}}

      iex> create_api(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_api(attrs \\ %{}) do
    %Api{}
    |> Api.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a api.

  ## Examples

      iex> delete_api(api)
      {:ok, %Api{}}

      iex> delete_api(api)
      {:error, %Ecto.Changeset{}}

  """
  def delete_api(%Api{} = api) do
    Repo.delete(api)
  end
end
