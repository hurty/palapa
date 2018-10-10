defmodule PalapaWeb.Document.PageController do
  use PalapaWeb, :controller

  plug(:put_navigation, "documents")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Documents", document_path(conn, :index, current_organization()))
  end
end
