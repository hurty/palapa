defmodule PalapaWeb.Public.DocumentControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Documents

  @doc_title "My awesome book"

  setup do
    workspace = insert_pied_piper!()
    {:ok, document} = Documents.create_document(workspace.gilfoyle, nil, %{title: @doc_title})
    {:ok, document} = Documents.generate_public_token(document)

    conn = login(workspace.gilfoyle)
    {:ok, conn: conn, member: workspace.gilfoyle, org: workspace.organization, document: document}
  end

  test "redirected to first page of the document", %{conn: conn, document: document} do
    conn =
      get(
        conn,
        public_document_path(
          conn,
          :show,
          document.public_token
        )
      )

    assert redirected_to(conn, 302) =~
             public_document_page_path(
               conn,
               :show,
               document.public_token,
               Documents.get_first_page(document)
             )
  end

  test "document with no pages", %{conn: conn, document: document} do
    first_page = Documents.get_first_page(document)
    Documents.delete_page!(first_page)

    conn = get(conn, public_document_path(conn, :show, document.public_token))

    assert html_response(conn, 200) =~ "This document is empty"
  end

  test "cannot access a deleted document", %{conn: conn, member: member, document: document} do
    Documents.delete_document!(document, member)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, public_document_path(conn, :show, document.public_token))
    end
  end
end
