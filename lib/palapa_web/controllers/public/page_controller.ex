defmodule PalapaWeb.Public.PageController do
  use PalapaWeb, :controller

  alias Palapa.Documents

  plug(:put_layout, "minimal.html")

  def show(conn, %{"document_id" => document_public_token, "id" => page_id}) do
    document = Documents.get_document_by_public_token!(document_public_token)

    page =
      Documents.non_deleted(Documents.Page)
      |> Documents.get_page!(page_id)

    previous_page = Documents.get_previous_page(page)
    next_page = Documents.get_next_page(page)

    conn
    |> render("show.html",
      page: page,
      previous_page: previous_page,
      next_page: next_page,
      document: document
    )
  end
end
