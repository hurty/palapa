defmodule PalapaWeb.Router do
  use PalapaWeb, :router

  pipeline :browser do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(Phoenix.LiveView.Flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    # sets current_account, current_member and current_organization
    plug(PalapaWeb.Authentication)
  end

  pipeline :authentication do
    plug(:enforce_authentication)
  end

  pipeline :billing do
    plug(:enforce_billing)
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

    resources("/password_reset", PasswordResetController,
      only: [:new, :create, :edit, :update],
      singleton: true
    )

    resources("/account", AccountController, only: [:edit, :update, :delete], singleton: true)

    get("/join/:invitation_id/:token", JoinController, :new)
    post("/join/:invitation_id/:token", JoinController, :create)

    scope(path: "/public", as: :public, alias: Public) do
      resources("/documents", DocumentController, only: [:show]) do
        resources("/pages", PageController, only: [:show])
      end
    end
  end

  scope("/", PalapaWeb) do
    pipe_through([:browser, :authentication])

    resources("/org", OrganizationController, as: nil, only: []) do
      scope "/settings", Settings, as: :settings do
        resources("/workspace", WorkspaceController, singleton: true)
        resources("/members", MemberController, only: [:index])
        resources("/customer", Billing.CustomerController, singleton: true)

        resources("/payment_method", Billing.PaymentMethodController,
          singleton: true,
          only: [:edit, :update]
        )

        resources("/payment_authentication", Billing.PaymentAuthenticationController)

        resources("/billing_error", Billing.BillingErrorController,
          only: [:show],
          singleton: true
        )
      end
    end
  end

  # Private pages for logged in members only
  scope "/", PalapaWeb do
    pipe_through([:browser, :authentication, :billing])

    resources("/workspaces", WorkspaceController, only: [:index])

    resources("/org", OrganizationController, as: nil, only: []) do
      get("/sketch", SketchController, :index)

      get("/sessions/switch_organization", SessionController, :switch_organization)
      get("/sessions/switcher", SessionController, :switcher)

      get("/", DashboardController, :index)
      get("/search", SearchController, :index)

      resources("/attachments", AttachmentController, only: [:create])
      resources("/trash", TrashController, only: [:index])

      # --- MESSAGES

      resources("/messages", MessageController) do
        resources("/comments", MessageCommentController, only: [:create])
      end

      resources("/messages/comments", MessageCommentController, only: [:edit, :update, :delete])

      # --- DOCUMENTS

      resources("/documents", Document.DocumentController) do
        resources("/trash", Document.DocumentTrashController,
          singleton: true,
          only: [:create, :delete],
          as: :trash
        )

        resources("/public_link", Document.DocumentPublicLinkController,
          singleton: true,
          only: [:create, :delete],
          as: :public_link
        )

        resources("/sections", Document.SectionController, only: [:create])
        resources("/page", Document.PageController, only: [:new, :create])
      end

      resources("/documents/sections", Document.SectionController,
        only: [:edit, :update, :delete],
        as: :document_section
      )

      resources("/documents/pages", Document.PageController,
        only: [:show, :edit, :update, :delete],
        as: :document_page
      ) do
        resources("/suggestions", Document.SuggestionController, only: [:index, :create])
      end

      resources("/documents/suggestions", Document.SuggestionController,
        only: [:edit, :update, :delete]
      ) do
        resources("/comments", Document.SuggestionCommentController,
          only: [:create],
          as: :comment
        )

        resources("/closure", Document.SuggestionClosureController,
          only: [:create, :delete],
          as: :closure,
          singleton: true
        )
      end

      resources("/documents/suggestions/comments", Document.SuggestionCommentController,
        only: [:edit, :update, :delete]
      )

      # --- MEMBERS

      resources "/members", MemberController, only: [:index, :show] do
        resources("/teams", TeamMemberController, only: [:edit, :update], singleton: true)
        resources("/member_informations", MemberInformationController, only: [:create])
      end

      resources("/member_informations", MemberInformationController,
        only: [:edit, :update, :delete]
      )

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

      # --- PROFILE

      resources("/profile", ProfileController, only: [:edit, :update])
    end
  end

  scope "/", PalapaWeb do
    post("/stripe_webhooks", Settings.Billing.StripeWebhookController, :create)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PalapaWeb do
  #   pipe_through :api
  # end
end
