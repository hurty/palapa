defmodule PalapaWeb.Document.DocumentPublicLinkController do
  use PalapaWeb, :controller

  alias PalapaWeb.Document.BaseController
  alias Palapa.Documents

  def create(conn, %{"document_id" => document_id}) do
    document = BaseController.find_document!(conn, document_id)
    Documents.generate_public_token(document)

    conn
    |> put_flash(:success, gettext("A secret link has been created for this document"))
    |> redirect(to: Routes.document_path(conn, :show, current_organization(conn), document))
  end

  def delete(conn, %{"document_id" => document_id}) do
    document = BaseController.find_document!(conn, document_id)
    Documents.destroy_public_token(document)

    conn
    |> put_flash(:success, gettext("The secret link for this document has been deleted"))
    |> redirect(to: Routes.document_path(conn, :show, current_organization(conn), document))
  end
end
