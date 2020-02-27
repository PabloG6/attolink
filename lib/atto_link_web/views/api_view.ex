defmodule AttoLinkWeb.ApiView do
  use AttoLinkWeb, :view
  alias AttoLinkWeb.ApiView

  def render("index.json", %{api_key: api_key}) do
    %{data: render_many(api_key, ApiView, "api.json")}
  end

  def render("show.json", %{api: api}) do
    %{data: render_one(api, ApiView, "api.json")}
  end

  def render("api.json", %{api: api}) do
    %{api_key: api.api_key, id: api.id, user_id: api.user_id}
  end
end
