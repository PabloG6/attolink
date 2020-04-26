defmodule AttoLinkWeb.PermissionsView do
  use AttoLinkWeb, :view
  alias AttoLinkWeb.PermissionsView

  def render("index.json", %{permissions: permissions}) do
    %{data: render_many(permissions, PermissionsView, "permissions.json")}
  end

  def render("show.json", %{permissions: permissions}) do
    %{data: render_one(permissions, PermissionsView, "permissions.json")}
  end

  def render("permissions.json", %{permissions: permissions}) do
    %{
      id: permissions.id,
      enable_whitelist: permissions.enable_whitelist
    }
  end
end
