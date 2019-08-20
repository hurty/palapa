defmodule PalapaWeb.Breadcrumbs do
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
