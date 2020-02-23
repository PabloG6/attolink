defmodule AttoLinkWeb.Router do
  use AttoLinkWeb, :router

  pipeline :api do
    plug :accepts, ["json", "html"]
  end

  scope "/api", AttoLinkWeb do
    pipe_through :api
  end

  scope "/", AttoLinkWeb do
    get "/", PreviewController, :create
  end
end
