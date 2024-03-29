defmodule PalapaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use PalapaWeb, :controller
      use PalapaWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: PalapaWeb
      import Plug.Conn
      import Palapa.Gettext
      import PalapaWeb.Current
      import PalapaWeb.Breadcrumbs
      import Bodyguard
      import Phoenix.LiveView.Controller, only: [live_render: 3]
      alias PalapaWeb.Router.Helpers, as: Routes

      # Handle authorization failures
      action_fallback(PalapaWeb.FallbackController)
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView
      import Bodyguard
      import Palapa.Gettext
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      import Bodyguard
      import Palapa.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/palapa_web/templates",
        namespace: PalapaWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import PalapaWeb.ErrorHelpers
      import Palapa.Gettext
      import Scrivener.HTML
      import Bodyguard

      import Phoenix.LiveView,
        only: [
          live_render: 2,
          live_render: 3,
          live_link: 1,
          live_link: 2,
          live_component: 2,
          live_component: 3,
          live_component: 4
        ]

      alias PalapaWeb.Helpers
      alias PalapaWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller

      import PalapaWeb.Authentication,
        only: [enforce_authentication: 2, put_organization_context: 2]

      import PalapaWeb.BillingPlug, only: [enforce_billing: 2]
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import Palapa.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
