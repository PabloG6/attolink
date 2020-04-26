defmodule AttoLinkWeb.PreviewController do
  use AttoLinkWeb, :controller
  alias AttoLink.Atto
  alias AttoLink.Atto.Preview
  action_fallback AttoLinkWeb.FallbackController

  def index(conn, _params) do
    preview = Atto.list_preview()
    render(conn, "index.json", preview: preview)
  end

  def create(conn, %{"url" => url, "cacheUrl" => "true"} = _query_params) do
    {:ok, user} = AttoLink.Auth.Api.current_user(conn)
    %Atto.Plan{preview_limit: preview_limit} = Atto.Plan.plan_type(user.plan)

    with {:allow, _count} <-
           Hammer.check_rate("link_preview:#{user.id}", 60_000 * 60, preview_limit),
         {:ok, %LinkPreview.Page{} = page_preview} <- Atto.create_preview(url),
         {:ok, %Preview{} = _cached_preview} <- Atto.cache_preview(user, page_preview) do
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

      {:deny, :exceeded_file_store_limit, limit} ->
        exceeded_file_store_limit(conn, limit)

      {:deny, limit} ->
        exceeded_preview_limit(conn, limit)

      {:error, :enoent} ->
        conn
        |> put_status(:internal_server_error)
        |> put_resp_header("content-type", "application/json")
        |> put_view(AttoLinkWeb.ErrorView)
        |> render(:error, message: "Failed to save your file. This is an internal server error")

      {:error, :enospc} ->
        conn
        |> put_status(:forbidden)
        |> put_resp_header("content-type", "application/json")
        |> put_view(AttoLinkWeb.ErrorView)
        |> render(:error, message: "Falied to save your file. You've exceeded your file limit")

      err ->
        err
    end
  end

  def create(conn, %{"url" => url, "cacheUrl" => "true", "async" => "true"} = params) do
    {:ok, user} = AttoLink.Auth.Api.current_user(params)
    %Atto.Plan{preview_limit: preview_limit} = Atto.Plan.plan_type(user.plan)

    with {:allow, _count} <-
           Hammer.check_rate("link_preview:#{user.id}", 60_000 * 60, preview_limit),
         {:ok, %LinkPreview.Page{} = preview} <- LinkPreview.create(url) do
      spawn(Atto, :cache_preview, [user, preview])

      conn
      |> put_status(:created)
      |> put_resp_header("content-type", "application/json")
      |> render("show.json", preview: preview)
    else
      {:deny, limit} ->
        conn
        |> put_status(:forbidden)
        |> put_resp_header("content-type", "application/json")
        |> put_view(AttoLinkWeb.ErrorView)
        |> render(:error, message: "You've exceeded your hourly preview limit", limit: limit)

      {:error, %LinkPreview.Error{}} = error ->
        error

      error ->
        error
    end
  end

  def create(conn, %{"url" => url} = _query_params) do
    {:ok, user} = AttoLink.Auth.Api.current_user(conn)
    %AttoLink.Atto.Plan{preview_limit: preview_limit} = AttoLink.Atto.Plan.plan_type(user.plan)

    with {:allow, count} <-
           Hammer.check_rate("link_preview:#{user.id}", 60_000 * 60, preview_limit),
         {:ok, %LinkPreview.Page{} = page_preview} <- Atto.create_preview(url) do
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
    conn
    |> put_status(:too_many_requests)
    |> put_view(AttoLinkWeb.ErrorView)
    |> render(:too_many_requests, limit: limit, limit_type: :too_many_preview_requests)
  end

  @spec exceeded_file_store_limit(Plug.Conn.t(), integer) :: Plug.Conn.t()
  defp exceeded_file_store_limit(conn, limit) do
    conn
    |> put_status(:too_many_requests)
    |> put_view(AttoLinkWeb.ErrorView)
    |> render(:too_many_requests, limit: limit, limit_type: :too_many_file_saves)
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
end
