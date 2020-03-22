defmodule AttoLinkWeb.Router do
  use AttoLinkWeb, :router
  use TODO

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :accept_html do
    plug :accepts, ["html"]
  end

  pipeline :auth do
    plug AttoLink.Auth.Pipeline
  end

  pipeline :api_auth do
    plug AttoLink.Auth.Api
  end

  @todo "0.0.1": "Create a login"
  scope "/", AttoLinkWeb do
    pipe_through [:api]
    post "/signup", UserController, :create
    post "/login", UserController, :login
  end

  scope "/", AttoLinkWeb do
    pipe_through [:api, :auth]
    resources "/user", UserController, except: [:new, :edit, :create]
    resources "/keys", ApiController, except: [:new, :edit]
  end

  scope "/api", AttoLinkWeb do
    pipe_through [:api, :api_auth]
    get "/preview", PreviewController, :create
  end


end
