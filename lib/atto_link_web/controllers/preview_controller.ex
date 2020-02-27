defmodule AttoLinkWeb.PreviewController do
  use AttoLinkWeb, :controller
  use TODO
  alias AttoLink.Atto
  alias AttoLink.Atto.Preview
  action_fallback AttoLinkWeb.FallbackController


  def index(conn, _params) do
    preview = Atto.list_preview()
    render(conn, "index.json", preview: preview)
  end

  @todo "fix error message to return appropriate error"
  def create(conn, %{"url" => url, "cacheUrl" => true} = _query_params) do
    with {:ok, %LinkPreview.Page{} = page_preview} <- Atto.create_preview(url),
         {:ok, %Preview{} = _cached_preview} <- Atto.cache_preview(page_preview) do
          conn
          |> put_status(:created)
          |> put_resp_header("content-type", "application/json")
          |> render("show.json", preview: page_preview)

    end

  end

  def create(conn, %{"url" => url} = _query_params) do
    user = Guardian.Plug.current_resource(conn)
    with {:allow, count} <- Hammer.check_rate("link_preview:#{user.id}", 60_000 * 60, 50),
      {:ok, %LinkPreview.Page{} = page_preview} <- Atto.create_preview(url) do

      conn
      |> put_status(:ok)
      |> put_resp_header("content-type", "application/json")
      |> render("show.json", preview: page_preview, count: count)

      else
        {:deny, limit} -> deny_limit(conn, limit)
        err -> err
    end
  end

  @spec deny_limit(Plug.Conn.t(), integer):: Plug.Conn.t()
  defp deny_limit(conn, limit) do
    conn
    |> put_status(:too_many_requests)
    |> put_view(AttoLinkWeb.ErrorView)
    |> render(:too_many_requests, limit: limit)
  end


  @todo "Fix this to return data saved in database along side user who saved it."
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

end
