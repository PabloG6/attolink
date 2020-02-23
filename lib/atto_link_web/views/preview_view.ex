defmodule AttoLinkWeb.PreviewView do
  use AttoLinkWeb, :view
  alias AttoLinkWeb.PreviewView

  def render("index.json", %{preview: preview}) do
    %{data: render_many(preview, PreviewView, "preview.json")}
  end

  def render("show.json", %{preview: preview}) do
    %{data: render_one(preview, PreviewView, "preview.json")}
  end

  def render("preview.json", %{preview: preview}) do

    %{
      original_url: preview.original_url,
      website_url: preview.website_url,
      title: preview.title,
      images: preview.images,
      description: preview.description
    }
  end
end
