defmodule AttoLinkWeb.PasswordController do
  use AttoLinkWeb, :controller

  alias AttoLink.Auth
  alias AttoLink.Auth.PasswordReset
  alias AttoLink.Repo

  action_fallback AttoLinkWeb.FallbackController

  def send_email(conn, %{"password" => %{"email" => email} = _password_params}) do

    with {:ok, %AttoLink.Accounts.User{} = user} <- AttoLink.Accounts.get_user_by(email: email),
        {:ok, %PasswordReset{id: id} = password_reset} <- Auth.create_password_reset(%{user: user}),
         :ok <- Auth.send_password_reset_email(email: email, id: id)
    do

      conn
      |> put_view(AttoLinkWeb.ResponseView)
      |> put_status(:ok)
      |> render(:show,
                message: "Please check your inbox for the link to reset your password",
                code: :password_reset_sent)
    else
      {:error, :user_not_found} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:not_found,
           Poison.encode!(%{
             errors: %{
               message: "Email does not exist",
               code: :email_not_exist

             }
           }))

      err ->
        conn
        |> send_resp(
          500,
          Poison.encode!(%{
            errors: %{
            message: "Server failed to process your request. Server may have experienced an unknown error or it may be down.",
            code: :password_reset_failed
          }})
        )
    end
  end




  def update(conn,
      %{"oldPassword" => old_password,
        "newPassword" => new_password}) do
       %AttoLink.Accounts.User{} = user = AttoLink.Auth.Guardian.Plug.current_resource(conn)
       with {:ok, %AttoLink.Accounts.User{}} <- Bcrypt.check_pass(user, old_password),
            {:ok, %AttoLink.Accounts.User{}} <- AttoLink.Accounts.update_user(user, %{password: new_password}) do
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(:ok, Poison.encode!(%{code: :password_reset, message: "We've reset your password"}))

        else
          {:error, "invalid password"} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(:unauthorized, Poison.encode!(%{
              data: %{
                message: "This password is invalid",
                code: :invalid_password,

              }}))
          err ->
            err

      end


  end



  def confirm_password_reset(conn,
  %{"id" => id,
    "password" => new_password}) do
      with  %PasswordReset{} = password <- Auth.get_password_reset(id) |> Repo.preload(:user),
        {:ok, %AttoLink.Accounts.User{} = user} <- AttoLink.Accounts.update_user(password.user, %{password: new_password}) do
        {:ok, token, _claims} = AttoLink.Auth.Guardian.encode_and_sign(user)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:ok, Poison.encode!(%{code: :password_reset, message: "We've reset your password", token: token}))

    else
      {:error, "invalid password"} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:unauthorized, Poison.encode!(%{
          data: %{
            message: "This password is invalid",
            code: :invalid_password,

          }}))

      {:error, :password_reset_not_found} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:not_found, Poison.encode!(%{
          data: %{
            message: "This entry either does not exist or has expired",
            code: :invalid_id,

          }}))
      err ->
        err

  end






end

end
