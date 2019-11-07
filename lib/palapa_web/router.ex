defmodule PalapaWeb.Router do
  use PalapaWeb, :router

  pipeline :browser do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(Phoenix.LiveView.Flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    # Sets current_account
    plug(PalapaWeb.Authentication)
  end

  pipeline :authentication do
    plug(:enforce_authentication)
  end

  pipeline :billing do
    plug(:enforce_billing)
  end

  pipeline :organization_context do
    plug(:put_organization_context)
  end

  pipeline :contact_navigation do
    plug(PalapaWeb.ContactNavigation)
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

    get("/join/:invitation_id/:token", JoinController, :new)
    post("/join/:invitation_id/:token", JoinController, :create)

    post("/stripe_webhooks", Billing.StripeWebhookController, :create)
  end

  scope(path: "/public", as: :public, alias: PalapaWeb.Public) do
    pipe_through(:browser)

    resources("/documents", DocumentController, only: [:show]) do
      resources("/pages", PageController, only: [:show])
    end
  end

  scope("/", PalapaWeb) do
    pipe_through([:browser, :authentication])

    resources("/account", AccountController, only: [:edit, :update, :delete], singleton: true)
    resources("/organizations", OrganizationController, only: [:index, :new, :create])
  end

  scope("/organizations/:organization_id", PalapaWeb) do
    pipe_through([:browser, :authentication, :organization_context])

    delete("/", OrganizationController, :delete)

    scope("/billing", Billing) do
      resources("/subscription", SubscriptionController, only: [:new, :create], singleton: true)

      post("/subscription/refresh", SubscriptionController, :refresh)

      resources("/payment_method", PaymentMethodController,
        only: [:edit, :update],
        singleton: true
      )

      resources("/payment", PaymentController, only: [:new], singleton: true)

      resources("/billing_error", BillingErrorController,
        only: [:show],
        singleton: true
      )
    end

    scope "/settings", Settings, as: :settings do
      resources("/workspace", WorkspaceController, singleton: true)
      resources("/members", MemberController, only: [:index])
      resources("/customer", Billing.CustomerController, singleton: true)

      resources("/payment_method", Billing.PaymentMethodController,
        singleton: true,
        only: [:edit, :update]
      )
    end
  end

  # Private pages for logged in members only
  scope("/organizations/:organization_id", PalapaWeb) do
    pipe_through([:browser, :authentication, :organization_context, :billing])

    get("/", DashboardController, :index)

    get("/sessions/switch_organization", SessionController, :switch_organization)

    get("/search", SearchController, :index)

    resources("/attachments", AttachmentController, only: [:create, :show])
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

    # --- CONTACTS

    scope "/" do
      pipe_through([:contact_navigation])
      live "/contacts", ContactLive, session: [:account_id]
      live "/contacts/new", ContactLive.New, session: [:account_id]
      live "/contacts/:id", ContactLive, session: [:account_id]
      live "/contacts/:id/edit", ContactLive.Edit, session: [:account_id]
    end

    # --- MEMBERS

    resources "/members", MemberController, only: [:index, :show] do
      resources("/teams", TeamMemberController, only: [:edit, :update], singleton: true)
      resources("/personal_informations", PersonalInformationController, only: [:create])
    end

    resources("/personal_informations", PersonalInformationController,
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

  # scope "/api", PalapaWeb do
  #   pipe_through :api
  # end
end
