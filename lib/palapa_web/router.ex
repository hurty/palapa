defmodule PalapaWeb.Router do
  use PalapaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PalapaWeb.Authentication
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PalapaWeb do
    pipe_through :browser # Use the default browser stack

    get "/", HomeController, :index
    resources "/registrations", RegistrationController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete], singleton: true
    get "/dashboard", DashboardController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PalapaWeb do
  #   pipe_through :api
  # end
end
