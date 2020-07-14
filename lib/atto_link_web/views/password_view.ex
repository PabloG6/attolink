defmodule AttoLinkWeb.PasswordView do
  use AttoLinkWeb, :view
  alias AttoLinkWeb.PasswordView

  def render("index.json", %{password_reset: password_reset}) do
    %{data: render_many(password_reset, PasswordView, "password.json")}
  end

  def render("show.json", %{password: password}) do
    %{data: render_one(password, PasswordView, "password.json")}
  end

  def render("password.json", %{password: password}) do
    %{id: password.id, email: password.email, is_reset: password.is_reset}
  end
end
