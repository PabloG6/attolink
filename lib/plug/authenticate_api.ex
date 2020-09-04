defmodule AttoLink.Auth.API do
  import Plug.Conn
  alias AttoLink.Accounts
  @admin_secret "ubPAbYOr2rNWgRDHLaac4aad+M5boGdMAcky5x3kEWA6lmsRNhBKSwmP+UKHHIps"
  @api_header_key  "teenie-api-key"
  @spec init(Keyword.t()) :: Keyword.t()
  def init(options), do: options

  @spec call(conn :: Plug.Conn.t(), opts :: Keyword.t()) :: Plug.Conn.t()
  def call(conn, _opts) do
    conn
    |> verify_user()

  end

  defp verify_admin(%Plug.Conn{} = conn) do
    with [key | _] <- get_req_header(conn, @api_header_key),
         true <- key == @admin_secret do

      {:ok, :admin}
    else
      _ ->
        {:error, :not_admin}

    end
  end

  defp verify_user(%Plug.Conn{} = conn) do
    with key <- fetch_key(conn),
         {:ok, %Accounts.User{}} = _user <- Accounts.get_user_by_api_key(key) do
      conn
    else
      nil ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> resp(
          401,
          Poison.encode!(%{
            message: "This api key does not coincide with a registered user.",
            response_code: :unregistered_api_key
          })
        )
        |> halt()

      {:error, :no_user} ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> resp(
          401,
          Poison.encode!(%{
            message: "This api key does not coincide with a registered user.",
            response_code: :unregistered_api_key
          })
        )
        |> send_resp()
        |> halt()

      {:error, :no_key} ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> resp(
          401,
          Poison.encode!(%{
            message: "No api key was sent with this request.",
            response_code: :missing_api_key
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
    |> resp(
      401,
      Poison.encode!(%{
        message: "This request has no api key contained in the request header. ",
        response_code: :missing_api_key
      })
    )
    |> send_resp()
    |> halt()
  end

  defp fetch_key(%Plug.Conn{} = conn) do
    case get_req_header(conn, @api_header_key) do
      [key | _tail] ->
        key

      [] = _err ->
        nil
    end
  end



  @spec current_user(conn :: Plug.Conn.t()) :: {:error, :no_user} | {:ok, any} | {:error, :no_key}
  def current_user(%Plug.Conn{} = conn) do
    key = fetch_key(conn)
    Accounts.get_user_by_api_key(key)
  end
end
