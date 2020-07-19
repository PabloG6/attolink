defmodule AttoLink.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias AttoLink.Repo
  alias SendGrid.Email
  alias AttoLink.Auth.PasswordReset

  @doc """
  Gets a single password.

  Raises `Ecto.NoResultsError` if the Password does not exist.

  ## Examples

      iex> get_password!(123)
      %Password{}

      iex> get_password!(456)
      ** (Ecto.NoResultsError)

  """
  def get_password_reset!(id), do: Repo.get!(PasswordReset, id)

  def get_password_reset(id) do
    with %PasswordReset{} = password_reset <- Repo.get(PasswordReset, id) do
      password_reset
    else
      nil ->
        {:error, :password_reset_not_found}
    end
  end

  @doc """
  Creates a password.

  ## Examples

      iex> create_password(%{field: value})
      {:ok, %Password{}}

      iex> create_password(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_password_reset(attrs) do
    %PasswordReset{}
    |> PasswordReset.changeset(attrs)
    |> Repo.insert(on_conflict: {:replace_all_except, [:inserted_at, :updated_at]}, conflict_target: [:user_id])
  end

  @doc """
  Updates a password.

  ## Examples

      iex> update_password(password, %{field: new_value})
      {:ok, %Password{}}

      iex> update_password(password, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def confirm_password_reset(%PasswordReset{} = password) do
    password
    |> PasswordReset.confirm_password_reset_changeset()
    |> Repo.update()
  end

  def send_password_reset_email(email: email, id: id) do
    Email.build()
    |> Email.add_to(email)
    |> Email.put_from("support@teenielink.dev")
    |> Email.put_subject("Reset your password.")
    |> Email.put_text(
      "Click the link below to reset your password. If you didn't ask for a link to reset your password, feel free to ignore it.\n #{Application.fetch_env!(:atto_link, :base_url)}/password_reset/#{
        id
      }"
    )
    |> SendGrid.Mail.send()
  end
end
