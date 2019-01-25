defmodule PalapaWeb.Document.PageControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Documents
  alias Palapa.Repo

  @doc_title "My awesome book"

  describe "as regular member" do
    setup do
      member = insert!(:member)

      conn =
        build_conn()
        |> assign(:current_member, member)
        |> assign(:current_account, member.account)
        |> assign(:current_organization, member.organization)

      {:ok, document} = Documents.create_document(member, nil, %{title: @doc_title})

      {:ok, conn: conn, member: member, org: member.organization, document: document}
    end

    test "new page", %{conn: conn, org: org, document: document} do
      conn = get(conn, document_page_path(conn, :new, org, document))
      assert html_response(conn, 200) =~ "New page"
    end

    test "show page", %{conn: conn, org: org, document: document} do
      conn = get(conn, document_page_path(conn, :show, org, document.main_page_id))
      assert html_response(conn, 200) =~ @doc_title
    end

    test "edit page", %{conn: conn, org: org, document: document} do
      conn = get(conn, document_page_path(conn, :edit, org, document.main_page_id))
      assert html_response(conn, 200)
    end

    test "update page", %{conn: conn, org: org, document: document} do
      payload = %{"page" => %{"title" => "My awesome page", "body" => "updated page content"}}

      conn =
        patch(
          conn,
          document_page_path(conn, :update, org, document.main_page_id, payload)
        )

      assert redirected_to(conn, 302) =~
               document_page_path(conn, :show, org, document.main_page_id)

      reloaded_page = Documents.get_page!(document.main_page_id)
      assert "updated page content" == reloaded_page.body
    end

    test "main page of a document can't be deleted", %{conn: conn, org: org, document: document} do
      assert_raise(Palapa.Documents.DeleteMainPageError, fn ->
        delete(
          conn,
          document_page_path(conn, :delete, org, document.main_page_id,
            current_page_id: document.main_page_id
          )
        )
      end)
    end

    test "delete page", %{conn: conn, org: org, member: member, document: document} do
      document = Repo.preload(document, :main_section)

      {:ok, page} = Documents.create_page(document.main_section, member, %{title: "new page"})

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

      conn =
        build_conn()
        |> assign(:current_member, workspace.gilfoyle)
        |> assign(:current_account, workspace.gilfoyle.account)
        |> assign(:current_organization, workspace.organization)

      {:ok, conn: conn, workspace: workspace}
    end

    test "a page of a document shared with everyone can be seen by anyone in the organization",
         %{
           conn: conn,
           workspace: workspace
         } do
      {:ok, document} = Documents.create_document(workspace.richard, nil, %{title: "Open doc"})

      conn =
        get(conn, document_page_path(conn, :show, workspace.organization, document.main_page_id))

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
        get(conn, document_page_path(conn, :show, workspace.organization, document.main_page_id))

      assert html_response(conn, 200) =~ "tech doc"
    end

    test "a page of a document shared with a specific team is not accessible by a member outside this team",
         %{conn: conn, workspace: workspace} do
      {:ok, document} =
        Documents.create_document(workspace.richard, workspace.management_team, %{
          title: "management doc"
        })

      assert_raise Ecto.NoResultsError, fn ->
        get(
          conn,
          document_page_path(conn, :show, workspace.organization, document.main_page_id)
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
          document_page_path(conn, :show, workspace.organization, document.main_page_id)
        )
      end
    end
  end
end
