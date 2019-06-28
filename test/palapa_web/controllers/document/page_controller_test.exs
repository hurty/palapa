defmodule PalapaWeb.Document.PageControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Documents

  @doc_title "My awesome book"

  describe "as regular member" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.gilfoyle)
      {:ok, document} = Documents.create_document(workspace.gilfoyle, nil, %{title: @doc_title})

      {:ok,
       conn: conn, member: workspace.gilfoyle, org: workspace.organization, document: document}
    end

    test "new page", %{conn: conn, org: org, document: document} do
      conn = get(conn, document_page_path(conn, :new, org, document))
      assert html_response(conn, 200) =~ "New page"
    end

    test "show page", %{conn: conn, org: org, document: document} do
      conn = get(conn, document_page_path(conn, :show, org, Documents.get_first_page(document)))
      assert html_response(conn, 200) =~ @doc_title
    end

    test "edit page", %{conn: conn, org: org, document: document} do
      conn = get(conn, document_page_path(conn, :edit, org, Documents.get_first_page(document)))
      assert html_response(conn, 200)
    end

    test "update page", %{conn: conn, org: org, document: document} do
      payload = %{"page" => %{"title" => "My awesome page", "content" => "updated page content"}}
      first_page = Documents.get_first_page(document)

      conn =
        patch(
          conn,
          document_page_path(conn, :update, org, first_page, payload)
        )

      assert redirected_to(conn, 302) =~ document_page_path(conn, :show, org, first_page)

      reloaded_page = Documents.get_page!(first_page.id)
      assert "updated page content" == to_string(reloaded_page.content)
    end

    test "delete page", %{conn: conn, org: org, member: member, document: document} do
      {:ok, page} = Documents.create_page(document, member, %{title: "new page"})

      conn =
        delete(
          conn,
          document_page_path(conn, :delete, org, page, current_page_id: page.id)
        )

      assert redirected_to(conn, 302)
    end
  end

  describe "page visibility" do
    setup do
      workspace = insert_pied_piper!(:full)
      conn = login(workspace.gilfoyle)

      {:ok, conn: conn, workspace: workspace}
    end

    test "a page of a document shared with everyone can be seen by anyone in the organization",
         %{
           conn: conn,
           workspace: workspace
         } do
      {:ok, document} = Documents.create_document(workspace.richard, nil, %{title: "Open doc"})

      conn =
        get(
          conn,
          document_page_path(
            conn,
            :show,
            workspace.organization,
            Documents.get_first_page(document)
          )
        )

      assert html_response(conn, 200) =~ "Open doc"
    end

    test "a page of a document shared with a specific team can be seen by a member in this team",
         %{
           conn: conn,
           workspace: workspace
         } do
      {:ok, document} =
        Documents.create_document(workspace.richard, workspace.tech_team, %{
          title: "tech doc"
        })

      conn =
        get(
          conn,
          document_page_path(
            conn,
            :show,
            workspace.organization,
            Documents.get_first_page(document)
          )
        )

      assert html_response(conn, 200) =~ "tech doc"
    end

    test "a page of a document shared with a specific team is not accessible by a member outside this team",
         %{conn: conn, workspace: workspace} do
      {:ok, document} =
        Documents.create_document(workspace.richard, workspace.management_team, %{
          title: "management doc"
        })

      first_page = Documents.get_first_page(document)

      assert_raise Ecto.NoResultsError, fn ->
        get(
          conn,
          document_page_path(
            conn,
            :show,
            workspace.organization,
            first_page
          )
        )
      end
    end

    test "a page of a document in an organization is not accessible from another organization", %{
      conn: conn,
      workspace: workspace
    } do
      workspace2 = insert_hooli!()

      {:ok, document} =
        Documents.create_document(workspace2.gavin, nil, %{
          title: "other workspace doc"
        })

      assert_raise Ecto.NoResultsError, fn ->
        get(
          conn,
          document_page_path(
            conn,
            :show,
            workspace.organization,
            Documents.get_first_page(document)
          )
        )
      end
    end
  end
end
