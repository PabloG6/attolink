defmodule AttoLink.Comms do
  @moduledoc """
  The Comms context.
  """

  import Ecto.Query, warn: false
  alias AttoLink.Repo
  alias SendGrid.Email
  alias AttoLink.Comms.ConfirmEmail

  @doc """
  Gets a single email.

  Raises `Ecto.NoResultsError` if the Email does not exist.

  ## Examples

      iex> get_email!(123)
      %Email{}

      iex> get_email!(456)
      ** (Ecto.NoResultsError)

  """
  def get_email!(id), do: Repo.get!(ConfirmEmail, id)



  @doc """
  Creates a email.

  ## Examples

      iex> create_email(%{field: value})
      {:ok, %Email{}}

      iex> create_email(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_email(attrs) do
    %ConfirmEmail{}
    |> ConfirmEmail.changeset(attrs)
    |> Repo.insert()
  end

  @spec send_confirm_email([{:email, binary} | {:id, any}, ...]) :: :ok | {:error, binary | [binary]}
  def send_confirm_email(email: email, id: id) do
    Email.build()
    |> Email.add_to(email)
    |> Email.put_from("support@teenielink.dev")
    |> Email.put_subject("Confirm your email address.")
    |> Email.put_text(
      "Click the link below to confirm your email address. If you didn't sign up to teenielink with this email, feel free to ignore it.\n http://localhost:4200/confirm_email/#{
        id
      }"
    )
    |> SendGrid.Mail.send()
  end

  @doc """
  Updates a email.

  ## Examples

      iex> update_email(email, %{field: new_value})
      {:ok, %Email{}}

      iex> update_email(email, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """


  def confirm_email(%ConfirmEmail{} = email) do
    email
    |> ConfirmEmail.update_confirm_changeset()
    |> Repo.update
  end
end
