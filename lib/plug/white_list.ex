defmodule AttoLink.Plug.WhiteList do
  import Plug.Conn
  import AttoLink.Auth.Api, only: [current_user: 1]
  alias AttoLink.Accounts
  @spec init(Keyword.t()) :: Keyword.t()
  def init(options), do: options

  @spec call(conn :: Plug.Conn.t(), opts :: Keyword.t()) :: Plug.Conn.t()
  def call(conn, _opts) do
    conn
    |> verify_whitelist()
  end

  defp verify_whitelist(conn) do

    to_string(:inet_parse.ntoa(conn.remote_ip))
    |> check_ip(conn)


  end

  @spec check_ip(ip :: String.t(), conn :: Plug.Conn.t()) :: Plug.Conn.t()
  defp check_ip(ip, %Plug.Conn{} = conn) do

    with {:ok, %AttoLink.Accounts.User{id: id} = user} <- current_user(conn),

        {:ok, %AttoLink.Security.Permissions{enable_whitelist: :restricted}}<- AttoLink.Security.get_permissions_by!(user_id: id),
    {:ok, _white_list} <- Accounts.verify_white_list(ip, user) do
      conn
    else
      {:error, :unverified_ip} ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> resp(401, Poison.encode!(%{message: "This ip address has not been white listed", response_code: :unregistered_ip}))
        |> send_resp()
        |> halt()


      {:ok, %AttoLink.Security.Permissions{enable_whitelist: :all}} ->
        conn
      {:ok, %AttoLink.Security.Permissions{enable_whitelist: :none}} ->
         conn
         |> put_resp_header("content-type", "application/json")
         |> resp(401, Poison.encode!(%{message: "This account has restricted all IPs", response_code: :restricted}))
         |> send_resp()
         |> halt()

        {:error, :no_permissions} ->
          #if the user has no permissions then just send the connection back anyway because it means the user has permitted all IPs
          # or has signed up through some other means.
          conn
        {:error, :no_user} ->
          conn
          |> put_resp_header("content-type", "application/json")
          |> resp(401, Poison.encode!(%{message: "You either have no api key or this is an unregistered api key", response_code: :unregistered_api_key}))
          |> send_resp()
          |> halt()



    end

  end
end
