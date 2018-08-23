defmodule PalapaWeb.Router do
  use PalapaWeb, :router

  pipeline :browser do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    # sets current_account, current_member and current_organization
    plug(PalapaWeb.Authentication)
  end

  pipeline :enforce_account_authentication do
    plug(:enforce_authentication)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  if Mix.env() == :dev do
    forward("/emails", Bamboo.SentEmailViewerPlug)
  end

  # Public pages
  scope "/", PalapaWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", HomeController, :index)
    resources("/registrations", RegistrationController, only: [:new, :create])
    resources("/sessions", SessionController, only: [:new, :create, :delete], singleton: true)
    get("/join/:invitation_id/:token", JoinController, :new)
    post("/join/:invitation_id/:token", JoinController, :create)
  end

  # Private pages for logged in members only
  scope "/", PalapaWeb do
    pipe_through([:browser, :enforce_account_authentication])

    resources("/org", OrganizationController, as: nil, only: []) do
      get("/sketch", SketchController, :index)
      get("/sessions/switch_organization", SessionController, :switch_organization)
      get("/sessions/switcher", SessionController, :switcher)
      get("/dashboard", DashboardController, :index)

      resources("/attachments", AttachmentController, only: [:create])

      resources("/messages", MessageController) do
        resources("/comments", MessageCommentController, only: [:create])
      end

      resources("/messages/comments", MessageCommentController, only: [:edit, :update, :delete])

      resources "/members", MemberController do
        resources("/teams", TeamMemberController, only: [:edit, :update], singleton: true)

        resources(
          "/member_informations",
          MemberInformationController,
          only: [:create, :update, :delete]
        )
      end

      resources("/invitations", InvitationController, only: [:new, :create, :delete]) do
        post("/renewal", InvitationController, :renew, as: :renew)
      end

      resources("/teams", TeamController, only: [:new, :create, :edit, :update]) do
        resources(
          "/membership",
          TeamMembershipController,
          only: [:create, :delete],
          singleton: true
        )
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", PalapaWeb do
  #   pipe_through :api
  # end
end
