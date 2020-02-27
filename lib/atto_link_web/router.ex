defmodule AttoLinkWeb.Router do
  use AttoLinkWeb, :router
  use TODO

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug AttoLink.Auth.Pipeline
  end

  @todo "0.0.1": "Create a login"
  scope "/", AttoLinkWeb do
    pipe_through [:api]
    post "/", UserController, :create
  end

  scope "/api", AttoLinkWeb do
    pipe_through [:api, :auth]
    get "/preview", PreviewController, :create
    resources "/user", UserController, except: [:new, :edit, :create]
    resources "/", ApiController, except: [:new, :edit]
  end
end
