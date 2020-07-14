defmodule Local do
  use HTTPoison.Base
  def process_request_url(endpoint) do
    AttoLinkWeb.Endpoint.url <> endpoint
  end

  def process_response_body(body) do
   response =  Poison.decode body
   response
  end

end
