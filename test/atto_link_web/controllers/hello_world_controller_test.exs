defmodule AttoLinkWeb.HelloWorldControllerTest do
  use AttoLinkWeb.ConnCase

  alias AttoLink.Greetings
  alias AttoLink.Greetings.HelloWorld



  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all hello_world", %{conn: conn} do
      conn = get(conn, Routes.hello_world_path(conn, :index))
      assert json_response(conn, 200)["info"] == "Hello World"
    end
  end






end
