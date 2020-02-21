defmodule AttoLinkWeb.PreviewController do
  use AttoLinkWeb, :controller

  alias AttoLink.Atto
  alias AttoLink.Atto.Preview
  alias LinkPreview.Page

  action_fallback AttoLinkWeb.FallbackController
  @type cache_preview :: {:ok, %Preview{}}

  def index(conn, _params) do
    preview = Atto.list_preview()
    render(conn, "index.json", preview: preview)
  end

  def create(conn, %{"url" => url} = _query_params) do

    IO.puts "Hello world"
    with {:ok, %LinkPreview.Page{} = page_preview} <- Atto.create_preview(url),
         {:ok, %Preview{} = cached_preview} <- Atto.cache_preview(page_preview) do
      IO.inspect(page_preview)

      conn
      |> put_status(:created)
      |> put_resp_header("content-type", "application/json")
      |> render("show.json", preview: page_preview)
    else
      err ->
        IO.puts(err)
    end
  end

  def show(conn, %{"url" => url}) do
    preview = Atto.get_preview!(url)

    render(conn, "show.json", preview: preview)
  end

  def update(conn, %{"id" => id, "preview" => preview_params}) do
    preview = Atto.get_preview!(id)

    with {:ok, %Preview{} = preview} <- Atto.update_preview(preview, preview_params) do
      render(conn, "show.json", preview: preview)
    end
  end

  def delete(conn, %{"id" => id}) do
    preview = Atto.get_preview!(id)

    with {:ok, %Preview{}} <- Atto.delete_preview(preview) do
      send_resp(conn, :no_content, "")
    end
  end

  @todo "0.0.1": "update this to cache the html page and then return {:ok}"
end
