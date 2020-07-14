defmodule AttoLinkWeb.HelloWorldController do
  use AttoLinkWeb, :controller


  action_fallback AttoLinkWeb.FallbackController

  def index(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, Poison.encode!(%{info: "Hello World"}))
  end



end
