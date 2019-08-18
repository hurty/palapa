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

  test "redirected to first page of the document", %{conn: conn, org: org, document: document} do
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
end
