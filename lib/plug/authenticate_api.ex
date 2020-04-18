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
         {:ok, %Accounts.User{}} = _user <- Accounts.get_user_by_api_key(key) do
      conn
    else
      nil ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> resp(401, Poison.encode!(%{message: "This api key seems to be unregistered", response_code: :unregistered_api_key}))
        |> halt()

      {:error, :no_user} ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> resp(
          401,
          Poison.encode!(%{
            message: "You either have no api key or this is an unregistered api key",
            response_code: :unregistered_api_key
          })
        )
        |> send_resp()
        |> halt()
    end
  end

  defp verify_user({:not_found, %Plug.Conn{} = conn}) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> resp(401, Poison.encode!(%{message: "no such api key exists"}))
    |> send_resp()
    |> halt()
  end

  defp verify_user({:no_key, %Plug.Conn{} = conn}) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> resp(401, Poison.encode!(%{message: "api key is missing"}))
    |> send_resp()
    |> halt()
  end

  defp fetch_key(%Plug.Conn{} = conn) do
    IO.inspect conn
    IO.puts "Hello World"
    IO.inspect conn.req_headers
    case get_req_header(conn, "api_key") do
      [key | _tail] ->
        key

      [] = _err ->
        nil
    end
  end

  @spec current_user(conn :: Plug.Conn.t()) :: {:error, :no_user} | {:ok, any}
  def current_user(conn) do
    key = fetch_key(conn)
    Accounts.get_user_by_api_key(key)
  end
end
