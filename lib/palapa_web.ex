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
      import PalapaWeb.Router.Helpers
      import PalapaWeb.Gettext
      import PalapaWeb.Current
      import Palapa.Access

      # Handle authorization failures
      action_fallback(PalapaWeb.FallbackController)

      def put_navigation(conn, value) do
        Plug.Conn.assign(conn, :navigation, value)
      end

      def put_breadcrumb(conn, title, href) do
        breadcrumbs = conn.assigns[:breadcrumbs] || []
        breadcrumbs = breadcrumbs ++ [List.wrap(title: title, href: href)]

        conn
        |> Plug.Conn.assign(:breadcrumbs, breadcrumbs)
      end
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

      import PalapaWeb.Router.Helpers
      import PalapaWeb.ErrorHelpers
      import PalapaWeb.Gettext
      import PalapaWeb.Helpers
      import Scrivener.HTML
      import Palapa.Access, only: [permit?: 4]
      import Palapa.RichText.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import PalapaWeb.Authentication, only: [enforce_authentication: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import PalapaWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
