defmodule AttoLinkWeb.PreviewControllerTest do
  use AttoLinkWeb.ConnCase

  alias AttoLink.Atto
  alias AttoLink.Atto.Preview
  alias AttoLink.Accounts
  @valid_url "https://pusher.com/"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create preview" do
    setup [:authenticate_user]

    test "renders preview when data is valid", %{conn: conn} do

      conn = get(conn, Routes.preview_path(conn, :create), url: @valid_url)

      assert %{
               "title" => title,
               "description" => description,
               "images" => images,
               "website_url" => websites_url,
               "original_url" => original_url
             } = json_response(conn, 200)["data"]
    end

    test "caches web page and renders preview when data is valid", %{conn: conn} do
      conn = get(conn, Routes.preview_path(conn, :create), url: @valid_url, cacheUrl: true)

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
    test "renders error when user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.preview_path(conn, :create, url: @valid_url))
      assert json_response(conn, 401) == %{"message" => "unauthenticated"}
    end
  end

  describe "check api limiter with authenticated user" do
    setup [:authenticate_user]
    test "renders error when user is not logged in", %{conn: conn, user: user} do

      {:ok, token, _} = AttoLink.Auth.Guardian.encode_and_sign(user)


      # call this connection four times.
      conn = build_conn() |> put_req_header("authorization", "bearer: "<> token)
      conn = get(conn, Routes.preview_path(conn, :create, url: @valid_url))


      conn = build_conn() |> put_req_header("authorization", "bearer: "<> token)
      conn = get(conn, Routes.preview_path(conn, :create, url: @valid_url))


      conn = build_conn() |> put_req_header("authorization", "bearer: "<> token)
      conn = get(conn, Routes.preview_path(conn, :create, url: @valid_url))


      conn = build_conn() |> put_req_header("authorization", "bearer: "<> token)
      conn = get(conn, Routes.preview_path(conn, :create, url: @valid_url))

      assert json_response(conn, 429)
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
end
