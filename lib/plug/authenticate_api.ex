defmodule AttoLink.Auth.Api do
  import Plug.Conn
  alias AttoLink.Accounts

  @spec init(Keyword.t()) :: Keyword.t()
  def init(options), do: options

  @spec call(conn :: Plug.Conn.t(), opts :: Keyword.t()) :: Plug.Conn.t()
  def call(conn, _opts) do
    conn
    |> verify_user()
  end



  defp verify_user(%Plug.Conn{} = conn) do

    with key <- fetch_key(conn),
        true <- is_binary(key),
        %Accounts.User{} = _user <- Accounts.get_user_by_api_key(key) do
      conn
    else
      _err ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> resp(401, Poison.encode!(%{message: "unauthenticated"}))
        |> send_resp()
        |> halt()
    end
  end

  defp verify_user({_error, conn}) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> resp(401, "unauthenticated")
    |> send_resp()
  end





  defp fetch_key(conn) do
    case get_req_header(conn, "api_key") do
     [key | _tail] ->
      key

      [] = err ->
        err


    end


  end

  def current_user(conn) do
    key = fetch_key(conn)
    Accounts.get_user_by_api_key(key)

  end
end
