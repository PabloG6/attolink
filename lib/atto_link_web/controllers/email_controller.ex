defmodule AttoLinkWeb.EmailController do
  use AttoLinkWeb, :controller

  alias AttoLink.Comms
  alias AttoLink.Comms.ConfirmEmail
  alias AttoLink.Repo
  action_fallback AttoLinkWeb.FallbackController

  def send_email(conn, %{"email" => email} = _params) do


    with {:ok, %AttoLink.Accounts.User{email: email} = user} <- AttoLink.Accounts.get_user_by(email: email),
        {:ok, %ConfirmEmail {id: id}} <-
           Comms.create_email(%{user: user, email: email}),
         :ok <- Comms.send_confirm_email(email: email, id: id) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(
        :ok,
        Poison.encode!(%{
          data: %{
            message: "Confirmation Email Sent!",
            code: :email_sent
          }
        })
      )
    else
      {:error, :user_not_found} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(422, Poison.encode!(%{
          errors: %{
            message: "No such email exists",
            code: :email_not_sent
          }
        }))
      {:error, error_message} ->
        conn
        |> send_resp(
          200,
          Poison.encode!(%{
            data: %{
              message: "Failed to send confirmation email",
              raw_message: error_message,
              code: :email_not_sent
            }
          })
        )

      err ->
        err
    end
  end

  def send_update_email(conn, %{"email" => email, "password" => password}) do
    user = AttoLink.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, %ConfirmEmail{email: email, id: id}} <- Comms.create_email(%{user: user, email: email}),
      :ok <- Comms.send_confirm_email(email: email, id: id),
      {:ok, _user} <- Bcrypt.check_pass(user, password)

      do
         conn
         |> put_resp_content_type("application/json")
         |> send_resp(:ok,
               Poison.encode!(%{
                      data: %{
                         message: "Confirmation email sent",
                         code: :email_sent
                    }
         }))
    else
      err ->

        err

    end



  end

  def confirm_update_email(conn, %{"id" => id}) do
    confirm_email = Comms.get_email!(id) |> Repo.preload(:user)
    with {:ok, %ConfirmEmail{email: email}} <- Comms.confirm_email(confirm_email),
         {:ok, %AttoLink.Accounts.User{} = user} <- AttoLink.Accounts.update_user(confirm_email.user, %{email: email}),
         {:ok, token, _claims} = AttoLink.Auth.Guardian.encode_and_sign(user)
    do

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:ok, Poison.encode!(%{
        data: %{message: "Confirmed updated email", code: :email_confirmed, token: token}
      }))
    end
  end


  def confirm_email_address(conn, %{"id" => id}) do
    email = Comms.get_email!(id)

    with {:ok, %ConfirmEmail{} = confirmed_email} <-
           email |> Comms.confirm_email() do
      render(conn, "show.json", email: confirmed_email)
    end
  end
end
