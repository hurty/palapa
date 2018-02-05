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

      # Handle authorization failures
      action_fallback(PalapaWeb.FallbackController)

      # Handy authorization functions
      defdelegate(permit(policy, action, user, params \\ []), to: Bodyguard)
      defdelegate(permit!(policy, action, user, params \\ []), to: Bodyguard)
      defdelegate(permit?(policy, action, user, params \\ []), to: Bodyguard)

      # Redefine the actions parameters: we pass the current user and organization for each action
      def action(conn, _) do
        current_user = Map.get(conn.assigns, :current_user)
        current_organization = Map.get(conn.assigns, :current_organization)

        apply(__MODULE__, action_name(conn), [
          conn,
          conn.params,
          %{user: current_user, organization: current_organization}
        ])
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
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import PalapaWeb.Authentication, only: [authenticate_user: 2]
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
