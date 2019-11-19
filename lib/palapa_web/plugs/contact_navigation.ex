defmodule PalapaWeb.ContactNavigation do
  import Plug.Conn
  import PalapaWeb.Breadcrumbs
  import PalapaWeb.Gettext
  alias PalapaWeb.Router.Helpers, as: Routes

  def init(options) do
    options
  end

  def call(conn, _params) do
    conn
    |> assign(:navigation, "contacts")
    |> put_breadcrumb(
      gettext("Contacts"),
      Routes.live_path(conn, PalapaWeb.ContactLive, conn.assigns.current_organization)
    )
  end
end
