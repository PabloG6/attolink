defmodule AttoLinkWeb.ErrorView do
  use AttoLinkWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def render("error.json", %{errors: %LinkPreview.Error{message: message, origin: origin}}) do
    %{detail: %{message: message, origin: origin}}
  end

  def render("401.json", %{message: message}) do
    %{detail: %{message: message}}
  end

  def render("401.json", _errors) do
    %{detail: %{message: "an unknown error has occured"}}
  end
end
