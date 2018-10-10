defmodule PalapaWeb.Document.PageController do
  use PalapaWeb, :controller

  alias Palapa.Documents

  def create(conn, %{"document_id" => document_id, "page" => page_params}) do
    document = Documents.get_document!(document_id)

    with :ok <- permit(Documents, :create_page, current_member(), document) do
      case Documents.create_page(document, current_member(), page_params) do
        {:ok, page} -> render(conn, "_page.html", layout: false, page: page)
        _ -> send_resp(conn, 400, "")
      end
    end
  end
end
