defmodule PalapaWeb.Document.SuggestionControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Documents

  @doc_title "My awesome book"

  setup do
    workspace = insert_pied_piper!()
    conn = login(workspace.gilfoyle)
    {:ok, document} = Documents.create_document(workspace.gilfoyle, nil, %{title: @doc_title})
    page = Documents.get_first_page(document)

    {:ok,
     conn: conn,
     member: workspace.gilfoyle,
     org: workspace.organization,
     document: document,
     page: page}
  end

  test "list open suggestions", %{conn: conn, org: org, member: member, page: page} do
    {:ok, _suggestion1} =
      Documents.Suggestions.create_suggestion(page, member, %{content: "Some great suggestion"})

    {:ok, suggestion2} =
      Documents.Suggestions.create_suggestion(page, member, %{content: "Another suggestion"})

    Documents.Suggestions.close_suggestion(suggestion2, member)

    conn = get(conn, document_page_suggestion_path(conn, :index, org, page))
    assert html_response(conn, 200) =~ "Some great suggestion"
    refute html_response(conn, 200) =~ "Another suggestion"
  end

  test "list closed suggestions", %{conn: conn, org: org, member: member, page: page} do
    {:ok, _suggestion1} =
      Documents.Suggestions.create_suggestion(page, member, %{content: "Some great suggestion"})

    {:ok, suggestion2} =
      Documents.Suggestions.create_suggestion(page, member, %{content: "Another suggestion"})

    Documents.Suggestions.close_suggestion(suggestion2, member)

    conn =
      get(conn, document_page_suggestion_path(conn, :index, org, page, %{"status" => "closed"}))

    assert html_response(conn, 200) =~ "Another suggestion"
    refute html_response(conn, 200) =~ "Some great suggestion"
  end

  test "create a new suggestion", %{conn: conn, org: org, page: page} do
    suggestion_payload = %{"suggestion" => %{"content" => "Some great suggestion"}}
    conn = post(conn, document_page_suggestion_path(conn, :create, org, page, suggestion_payload))
    assert html_response(conn, 200) =~ "Some great suggestion"
  end

  test "edit a suggestion", %{conn: conn, org: org, member: member, page: page} do
    {:ok, suggestion} =
      Documents.Suggestions.create_suggestion(page, member, %{content: "Some great suggestion"})

    conn = get(conn, suggestion_path(conn, :edit, org, suggestion))
    assert html_response(conn, 200) =~ "Some great suggestion"
  end

  test "update a suggestion successfully", %{conn: conn, org: org, member: member, page: page} do
    {:ok, suggestion} =
      Documents.Suggestions.create_suggestion(page, member, %{content: "Some great suggestion"})

    suggestion_payload = %{"suggestion" => %{"content" => "Another idea"}}
    conn = patch(conn, suggestion_path(conn, :update, org, suggestion, suggestion_payload))
    assert html_response(conn, 200) =~ "Another idea"
  end

  test "delete a suggestion", %{conn: conn, org: org, member: member, page: page} do
    {:ok, suggestion} =
      Documents.Suggestions.create_suggestion(page, member, %{content: "Some great suggestion"})

    conn = delete(conn, suggestion_path(conn, :delete, org, suggestion))
    assert conn.status == 204
  end
end
