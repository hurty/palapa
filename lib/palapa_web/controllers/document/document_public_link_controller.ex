defmodule PalapaWeb.Document.DocumentPublicLinkController do
  use PalapaWeb, :controller

  import PalapaWeb.Document.BaseController

  alias Palapa.Documents

  def create(conn, %{"document_id" => document_id}) do
    document = find_document!(conn, document_id)
    Documents.generate_public_token(document)

    conn
    |> put_flash(:success, "A secret link has been created for this document")
    |> redirect(to: document_path(conn, :show, current_organization(), document))
  end

  def delete(conn, %{"document_id" => document_id}) do
    document = find_document!(conn, document_id)
    Documents.destroy_public_token(document)

    conn
    |> put_flash(:success, "The secret link for this document has been deleted")
    |> redirect(to: document_path(conn, :show, current_organization(), document))
  end
end
