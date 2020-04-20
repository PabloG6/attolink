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

  @spec authenticate_user(User.t()) :: any
  def authenticate_user(%User{email: email, password: password}) do
    Repo.get_by(User, email: email)
    |> check_pass(password)
  end

  @spec get_by(any()) :: any
  def get_by(info) do
    Repo.get_by(User, info)
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

  @doc """
  returns a user based on an api key.

  iex> get_user_by_api_key(api_key)
  %User{}

  """

  def get_user_by_api_key(nil) do
    IO.puts("API KEY IS NULL")
    {:error, :no_key}
  end

  @spec get_user_by_api_key(api_key :: String.t() | nil) ::
          {:ok, %User{}} | {:error, :no_user} | {:error, :no_key}
  def get_user_by_api_key(api_key) do
    with %Api{} = api <-
           Repo.get_by(Api, api_key: api_key)
           |> Repo.preload(:user) do
      {:ok, api.user}
    else
      nil ->
        {:error, :no_user}
    end
  end

  alias AttoLink.Accounts.WhiteList

  @doc """
  Returns the list of whitelist.

  ## Examples

      iex> list_whitelist()
      [%WhiteList{}, ...]

  """
  def list_whitelist do
    Repo.all(WhiteList)
  end

  @doc """
  Gets a single white_list.

  Raises `Ecto.NoResultsError` if the White list does not exist.

  ## Examples

      iex> get_white_list!(123)
      %WhiteList{}

      iex> get_white_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_white_list!(id), do: Repo.get!(WhiteList, id)

  @doc """
  Creates a white_list.

  ## Examples

      iex> create_white_list(%{field: value})
      {:ok, %WhiteList{}}

      iex> create_white_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_white_list(attrs \\ %{}) do
    %WhiteList{}
    |> WhiteList.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a white_list.

  ## Examples

      iex> update_white_list(white_list, %{field: new_value})
      {:ok, %WhiteList{}}

      iex> update_white_list(white_list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_white_list(%WhiteList{} = white_list, attrs) do
    white_list
    |> WhiteList.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a white_list.

  ## Examples

      iex> delete_white_list(white_list)
      {:ok, %WhiteList{}}

      iex> delete_white_list(white_list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_white_list(%WhiteList{} = white_list) do
    Repo.delete(white_list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking white_list changes.

  ## Examples

      iex> change_white_list(white_list)
      %Ecto.Changeset{source: %WhiteList{}}

  """
  def change_white_list(%WhiteList{} = white_list) do
    WhiteList.changeset(white_list, %{})
  end

  @spec verify_white_list(ip :: String.t(), AttoLink.Accounts.User.t()) ::
          {:ok, AttoLink.Accounts.WhiteList.t()} | {:error, :unverified_ip}
  def verify_white_list(ip, %User{id: id}) do
    with %WhiteList{} = white_list <- Repo.get_by(WhiteList, ip_address: ip, user_id: id) do
      {:ok, white_list}
    else
      nil -> {:error, :unverified_ip}
    end
  end
end
