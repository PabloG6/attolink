defmodule AttoLinkWeb.HelloWorldView do
  use AttoLinkWeb, :view
  alias AttoLinkWeb.HelloWorldView

  def render("index.json", %{hello_world: hello_world}) do
    %{data: render_many(hello_world, HelloWorldView, "hello_world.json")}
  end

  def render("show.json", %{hello_world: hello_world}) do
    %{data: render_one(hello_world, HelloWorldView, "hello_world.json")}
  end

  def render("hello_world.json", %{hello_world: hello_world}) do
    %{id: hello_world.id}
  end
end
