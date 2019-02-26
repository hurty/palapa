defmodule PalapaWeb.Public.DocumentController do
  use PalapaWeb, :controller

  alias Palapa.Documents

  plug(:put_layout, "minimal.html")

  def show(conn, %{"id" => token}) do
    document = Documents.get_document_by_public_token!(token)

    first_page = Documents.get_first_page(document)

    if first_page do
      redirect(conn, to: public_document_page_path(conn, :show, document.public_token, first_page))
    else
      render(conn, "show.html", document: document)
    end
  end
end
