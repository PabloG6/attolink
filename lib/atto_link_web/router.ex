defmodule AttoLinkWeb.Router do
  use AttoLinkWeb, :router

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
    plug AttoLink.Auth.API
  end

  pipeline :white_list do
    plug AttoLink.Plug.WhiteList
  end

  scope "/", AttoLinkWeb do
    pipe_through [:api]
    post "/signup", UserController, :create
    post "/login", UserController, :login
    post "/confirm_email", EmailController, :send_email
    put "/confirm_email/:id", EmailController, :confirm_email_address
    put "/confirm_email/update/:id", EmailController, :confirm_update_email

    post "/auth/password/", PasswordController, :send_email
    post "/auth/password/:id", PasswordController, :confirm_password_reset
  end

  scope "/", AttoLinkWeb do
    pipe_through [:api, :auth]
    resources "/user", UserController, except: [:new, :edit, :create, :delete]
    delete "/user", UserController, :delete
    resources "/keys", ApiController, except: [:new, :edit, :update]
    resources "/whitelist", WhiteListController, except: [:new, :edit]
    resources "/subscriptions", SubscriptionController, except: [:new, :edit, :update, :index]
    resources "/permissions", PermissionsController, except: [:new, :edit, :show, :update, :index]
    get "/auth/check_token", UserController, :check_token
    put "/subscriptions", SubscriptionController, :update
    get "/permissions", PermissionsController, :show
    put "/permissions", PermissionsController, :update
    patch "/permissions", PermissionsController, :update
    post "/confirm_email/update", EmailController, :send_update_email
    put "/auth/password", PasswordController, :update
  end




  scope "/v1", AttoLinkWeb do
    pipe_through [:api]
    get "/plans", SubscriptionController, :index
  end

  scope "/v1", AttoLinkWeb do
    pipe_through [:api, :white_list, :api_auth]
    get "/preview", PreviewController, :create
  end
end
