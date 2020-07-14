defmodule AttoLinkWeb.WhiteListView do
  use AttoLinkWeb, :view
  alias AttoLinkWeb.WhiteListView

  def render("index.json", %{whitelist: whitelist}) do
    %{data: render_many(whitelist, WhiteListView, "white_list.json")}
  end

  def render("show.json", %{white_list: white_list}) do
    %{data: render_one(white_list, WhiteListView, "white_list.json")}
  end

  def render("white_list.json", %{white_list: white_list}) do
    %{
      id: white_list.id,
      ip_address: white_list.ip_address,
      inserted_at: white_list.inserted_at,
      type: white_list.type
    }
  end
end
