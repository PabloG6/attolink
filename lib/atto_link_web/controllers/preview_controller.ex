defmodule AttoLinkWeb.PreviewController do
  use AttoLinkWeb, :controller
  use TODO
  alias AttoLink.Atto
  alias AttoLink.Atto.Preview
  action_fallback AttoLinkWeb.FallbackController
  @dev_preview_plan 3
  def index(conn, _params) do
    preview = Atto.list_preview()
    render(conn, "index.json", preview: preview)
  end

  @todo "fix error message to return appropriate error"
  @todo "fix this to "
  def create(conn, %{"url" => url, "cacheUrl" => true} = _query_params) do
    user = Guardian.Plug.current_resource(conn)

    with {:allow, count} <-
           Hammer.check_rate("link_preview: #{user.id}", 60_000 * 0.25, 3),
         {:ok, %LinkPreview.Page{} = page_preview} <- Atto.create_preview(url),
         {:ok, %Preview{} = _cached_preview} <- Atto.cache_preview(user, page_preview) do
          IO.puts "count: #{count}"
      conn
      |> put_status(:created)
      |> put_resp_header("content-type", "application/json")
      |> render("show.json", preview: page_preview)
    else
      {:error, %Ecto.Changeset{}} = error ->
        error

      {:error, %LinkPreview.Error{} = error} ->
        conn
        |> put_status(:internal_server_error)
        |> put_view(AttoLinkWeb.ErrorView)
        |> render(:error, errors: error)
      {:error, :exceeded_file_store_limit, limit} ->
        exceeded_file_store_limit(conn, limit)

      {:deny, limit} ->
        exceeded_preview_limit(conn, limit)

      {:error, :enoent}->
        conn
        |> put_status(:internal_server_error)
        |> put_resp_header("content-type", "application/json")
        |> put_view(AttoLinkWeb.ErrorView)
        |> render(:error, message: "Failed to save your file. This is an internal server error")
      {:error, :enospc} ->
        conn
        |> put_status(:internal_server_error)
        |> put_resp_header("content-type", "application/json")
        |> put_view(AttoLinkWeb.ErrorView)
        |> render(:error, message: "Falied to save your file. You've exceeded your file limit")


    end
  end

  def create(conn, %{"url" => url} = _query_params) do
    user = Guardian.Plug.current_resource(conn)

    with {:allow, count} <-
           Hammer.check_rate("link_preview:#{user.id}", 60_000 * 60, @dev_preview_plan),
         {:ok, %LinkPreview.Page{} = page_preview} <- Atto.create_preview(url) do
      IO.puts("fucking hell")

      conn
      |> put_status(:ok)
      |> put_resp_header("content-type", "application/json")
      |> render("show.json", preview: page_preview, limit: count)
    else
      {:deny, limit} -> exceeded_preview_limit(conn, limit)
      err -> err
    end
  end

  @spec exceeded_preview_limit(Plug.Conn.t(), integer) :: Plug.Conn.t()
  defp exceeded_preview_limit(conn, limit) do
    IO.puts("exceeded preview limit")

    conn
    |> put_status(:too_many_requests)
    |> put_view(AttoLinkWeb.ErrorView)
    |> render(:too_many_requests, limit: limit, limit_type: :too_many_preview_requests)
  end

  @spec exceeded_file_store_limit(Plug.Conn.t(), integer) :: Plug.Conn.t()
  @todo "Fix this to have a specific error for exceeding file storage"
  defp exceeded_file_store_limit(conn, limit) do
    IO.puts("exceeded file store limit")

    conn
    |> put_status(:too_many_requests)
    |> put_view(AttoLinkWeb.ErrorView)
    |> render(:too_many_requests, limit: limit, limit_type: :too_many_file_saves)
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
