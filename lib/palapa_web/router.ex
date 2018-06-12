defmodule PalapaWeb.Router do
  use PalapaWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    # sets current_member and current_organization if they are in session
    plug(PalapaWeb.Authentication)
  end

  pipeline :enforce_authentication do
    plug(:authenticate_account)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  if Mix.env() == :dev do
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)
  end

  # Public pages
  scope "/", PalapaWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", HomeController, :index)
    resources("/registrations", RegistrationController, only: [:new, :create])
    resources("/sessions", SessionController, only: [:new, :create, :delete], singleton: true)
  end

  # Private pages for logged in members only
  scope "/", PalapaWeb do
    pipe_through([:browser, :enforce_authentication])

    get("/sessions/switch_organization", SessionController, :switch_organization)
    get("/sessions/switcher", SessionController, :switcher)
    get("/dashboard", DashboardController, :index)

    resources("/attachments", AttachmentController, only: [:create, :delete])

    resources("/messages", MessageController) do
      resources("/comments", MessageCommentController, only: [:create, :edit, :update, :delete])
    end

    resources "/members", MemberController do
      resources("/teams", TeamMemberController, only: [:edit, :update], singleton: true)
    end

    resources("/invitations", InvitationController)
    resources("/teams", TeamController, only: [:new, :create])
  end

  # Other scopes may use custom stacks.
  # scope "/api", PalapaWeb do
  #   pipe_through :api
  # end
end
