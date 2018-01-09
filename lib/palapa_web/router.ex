defmodule PalapaWeb.Router do
  use PalapaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PalapaWeb.Authentication # sets current_user and current_organization if they are in session
  end

  pipeline :enforce_authentication do
    plug :authenticate_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public pages
  scope "/", PalapaWeb do
    pipe_through :browser # Use the default browser stack

    get "/", HomeController, :index
    resources "/registrations", RegistrationController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete], singleton: true
  end
  
  # Private pages for logged in users only
  scope "/", PalapaWeb do
    pipe_through [:browser, :enforce_authentication]

    get "/dashboard", DashboardController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PalapaWeb do
  #   pipe_through :api
  # end
end
