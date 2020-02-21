defmodule AttoLinkWeb.Router do
  use AttoLinkWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AttoLinkWeb do
    pipe_through :api
  end

  scope "/", AttoLinkWeb do
    resources "/", PreviewController, except: [:new, :edit]
  end
end
