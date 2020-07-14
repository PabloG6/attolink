defmodule AttoLinkWeb.EmailView do
  use AttoLinkWeb, :view
  alias AttoLinkWeb.EmailView

  def render("index.json", %{confirm_email: confirm_email}) do
    %{data: render_many(confirm_email, EmailView, "email.json")}
  end

  def render("show.json", %{email: email}) do
    %{data: render_one(email, EmailView, "email.json")}
  end

  def render("email.json", %{email: email}) do
    %{id: email.id}
  end
end
