defmodule AttoLinkWeb.PreviewControllerTest do
  use AttoLinkWeb.ConnCase

  alias AttoLink.Atto
  alias AttoLink.Atto.Preview

  @valid_url "https://pusher.com"

  def fixture(:preview) do
    {:ok, preview} = Atto.create_preview(@create_attrs)
    preview
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create preview" do
    test "renders preview when data is valid", %{conn: conn} do
      # conn = post(conn, Routes.preview_path(conn, :create), preview: @create_attrs)
      # assert %{"id" => id} = json_response(conn, 201)["data"]

      # conn = get(conn, Routes.preview_path(conn, :show, id))

      # assert %{
      #          "id" => id
      #        } = json_response(conn, 200)["data"]
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
      assert %{"title" => title,
              "description" => description,
              "images" => images,
              "website_url" => website_url,
              "original_url" => original_url} = json_response(conn, 201)["data"]
    end
  end

  defp create_preview(_) do
    preview = fixture(:preview)
    {:ok, preview: preview}
  end
end
