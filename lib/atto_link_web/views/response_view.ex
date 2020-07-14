defmodule AttoLinkWeb.ResponseView do
  use AttoLinkWeb, :view



  def render("show.json", %{message: message, code: code}) do
    %{data: %{
      message: message,
      code: code
    }}
  end


end
