defmodule AttoLinkWeb.PreviewControllerTest do
  use AttoLinkWeb.ConnCase

  alias AttoLink.Accounts
  @valid_url "https://pusher.com/"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @tag :preview
  describe "create preview" do
    setup [:authenticate_user, :authenticate_api]

    test "renders preview when data is valid", %{conn: conn, key: key} do
      conn = put_req_header(conn, "apikey", key.api_key)
      conn = get(conn, Routes.preview_path(conn, :create), url: @valid_url)

      assert %{
               "title" => title,
               "description" => description,
               "images" => images,
               "website_url" => websites_url,
               "original_url" => original_url
             } = json_response(conn, 200)["data"]
    end

    @tag :preview

    test "caches web page and renders preview when data is valid", %{conn: conn, key: key} do
      conn = put_req_header(conn, "apikey", key.api_key)

      conn = get(conn, Routes.preview_path(conn, :create), url: @valid_url, cacheUrl: "true")

      assert %{
               "title" => title,
               "description" => description,
               "images" => images,
               "website_url" => website_url,
               "original_url" => original_url
             } = json_response(conn, 201)["data"]
    end
  end

  describe "create preview with unauthenticated user" do
    setup [:authenticate_api]

    test "renders error when user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.preview_path(conn, :create, url: @valid_url))

      assert json_response(conn, 401) == %{
               "message" => "No api key was sent with this request.",
               "response_code" => "missing_api_key"
             }
    end
  end

  describe "check api limiter with authenticated user" do
    setup [:authenticate_api]

    test "renders error when user is not logged in", %{conn: conn, key: key} do
      # call this connection four times.
      conn = recycle(conn) |> put_req_header("apikey", key.api_key)
      conn = get(conn, Routes.preview_path(conn, :create, url: @valid_url))

      conn = recycle(conn) |> put_req_header("apikey", key.api_key)
      conn = get(conn, Routes.preview_path(conn, :create, url: @valid_url))

      conn = recycle(conn) |> put_req_header("apikey", key.api_key)
      conn = get(conn, Routes.preview_path(conn, :create, url: @valid_url))

      conn = recycle(conn) |> put_req_header("apikey", key.api_key)
      conn = get(conn, Routes.preview_path(conn, :create, url: @valid_url))

      assert json_response(conn, 200)
    end
  end

  defp authenticate_user(%{conn: conn}) do
    {:ok, user} = Accounts.create_user(%{email: "some email", password: "some password"})
    {:ok, token, _claims} = AttoLink.Auth.Guardian.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("authorization", "bearer: " <> token)

    {:ok, conn: conn, user: user}
  end

  defp authenticate_api(%{conn: conn}) do
    {:ok, user} = Accounts.create_user(%{email: "some email", password: "some password"})
    {:ok, key} = Accounts.create_api(%{user_id: user.id})
    {:ok, conn: conn, user: user, key: key}
  end
end
