defmodule PalapaWeb.Document.SuggestionClosureControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Documents

  @doc_title "My awesome book"
  @suggestion_content "Some great suggestion"

  setup do
    workspace = insert_pied_piper!()
    conn = login(workspace.gilfoyle)
    {:ok, document} = Documents.create_document(workspace.gilfoyle, nil, %{title: @doc_title})
    page = Documents.get_first_page(document)

    {:ok, suggestion} =
      Documents.Suggestions.create_suggestion(page, workspace.gilfoyle, %{
        content: @suggestion_content
      })

    {:ok,
     conn: conn,
     member: workspace.gilfoyle,
     org: workspace.organization,
     document: document,
     page: page,
     suggestion: suggestion}
  end

  test "close a suggestion", %{conn: conn, org: org, suggestion: suggestion} do
    conn = post(conn, suggestion_closure_path(conn, :create, org, suggestion))
    assert conn.status == 204
  end

  test "reopen a suggestion", %{conn: conn, org: org, member: member, suggestion: suggestion} do
    Documents.Suggestions.close_suggestion(suggestion, member)
    conn = delete(conn, suggestion_closure_path(conn, :delete, org, suggestion))
    assert conn.status == 204
  end
end
