defmodule PalapaWeb.Document.SuggestionCommentControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Documents

  @doc_title "My awesome book"
  @suggestion_comment_content "<div>It is a great idea</div>"

  setup do
    workspace = insert_pied_piper!()
    conn = login(workspace.gilfoyle)
    {:ok, document} = Documents.create_document(workspace.gilfoyle, nil, %{title: @doc_title})
    page = Documents.get_first_page(document)

    {:ok, suggestion} =
      Documents.Suggestions.create_suggestion(page, workspace.gilfoyle, %{
        content: "I have an idea"
      })

    {:ok, comment} =
      Documents.Suggestions.create_suggestion_comment(suggestion, workspace.gilfoyle, %{
        content: @suggestion_comment_content
      })

    {:ok,
     conn: conn,
     member: workspace.gilfoyle,
     admin: workspace.richard,
     org: workspace.organization,
     suggestion: suggestion,
     comment: comment}
  end

  test "create a comment to a suggestion", %{conn: conn, org: org, suggestion: suggestion} do
    comment_payload = %{"suggestion_comment" => %{"content" => @suggestion_comment_content}}

    conn =
      post(conn, Routes.suggestion_comment_path(conn, :create, org, suggestion, comment_payload))

    assert html_response(conn, 200) =~ @suggestion_comment_content
  end

  test "edit a reply to a suggestion", %{conn: conn, org: org, comment: comment} do
    conn = get(conn, Routes.suggestion_comment_path(conn, :edit, org, comment))
    assert html_response(conn, 200) =~ "It is a great idea"
  end

  test "update a reply to a suggestion", %{conn: conn, org: org, comment: comment} do
    comment_payload = %{"suggestion_comment" => %{"content" => "It is a terrific idea"}}

    conn =
      patch(conn, Routes.suggestion_comment_path(conn, :update, org, comment, comment_payload))

    assert html_response(conn, 200) =~ "It is a terrific idea"
  end

  test "a user cannot update a comment if he's not the author", %{
    conn: conn,
    org: org,
    admin: admin,
    comment: comment
  } do
    comment_payload = %{"suggestion_comment" => %{"content" => "It is a terrific idea"}}

    conn =
      login(admin)
      |> patch(Routes.suggestion_comment_path(conn, :update, org, comment, comment_payload))

    assert html_response(conn, 403)
  end

  test "an admin can delete any comment", %{conn: conn, org: org, admin: admin, comment: comment} do
    conn =
      login(admin)
      |> delete(Routes.suggestion_comment_path(conn, :delete, org, comment))

    assert conn.status == 204
  end

  test "delete a comment to a suggestion", %{conn: conn, org: org, comment: comment} do
    conn = delete(conn, Routes.suggestion_comment_path(conn, :delete, org, comment))
    assert conn.status == 204
  end

  test "a regular member cannot delete a comment made by another member", %{
    conn: conn,
    org: org,
    admin: admin,
    suggestion: suggestion
  } do
    {:ok, comment} =
      Documents.Suggestions.create_suggestion_comment(suggestion, admin, %{
        content: @suggestion_comment_content
      })

    conn = delete(conn, Routes.suggestion_comment_path(conn, :delete, org, comment))
    assert conn.status == 403
  end
end
