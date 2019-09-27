defmodule PalapaWeb.Public.PageControllerTest do
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

  test "show page", %{conn: conn, document: document} do
    conn =
      get(
        conn,
        Routes.public_document_page_path(
          conn,
          :show,
          document.public_token,
          Documents.get_first_page(document)
        )
      )

    assert html_response(conn, 200) =~ @doc_title
  end

  test "cannot show a page of a deleted document", %{
    conn: conn,
    member: member,
    document: document
  } do
    Documents.delete_document!(document, member)

    assert_raise Ecto.NoResultsError, fn ->
      get(
        conn,
        Routes.public_document_page_path(
          conn,
          :show,
          document.public_token,
          Documents.get_first_page(document)
        )
      )
    end
  end
end
