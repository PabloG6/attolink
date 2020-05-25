defmodule AttoLinkWeb.UserView do
  use AttoLinkWeb, :view
  alias AttoLinkWeb.UserView

  def render("index.json", %{user: user}) do
    %{data: render_many(user, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, email: user.email}
  end

  def render("login.json", %{user: user, token: token}) do
    %{data: %{email: user.email, id: user.id, token: token}}
  end

  def render("signup.json", %{user: user, token: token}) do
    %{data: %{email: user.email, id: user.id, token: token}}
  end
end
