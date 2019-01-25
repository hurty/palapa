defmodule PalapaWeb.Document.DocumentControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Documents
  alias Palapa.Documents.Document
  alias Palapa.Repo
  alias Ecto.Query

  describe "as regular member" do
    setup do
      member = insert!(:member)

      conn =
        build_conn()
        |> assign(:current_member, member)
        |> assign(:current_account, member.account)
        |> assign(:current_organization, member.organization)

      {:ok, conn: conn, member: member, org: member.organization}
    end

    test "list all documents", %{conn: conn, org: org} do
      conn = get(conn, document_path(conn, :index, org))
      assert html_response(conn, 200)
    end

    test "new document form", %{conn: conn, org: org} do
      conn = get(conn, document_path(conn, :new, org))
      assert html_response(conn, 200)
    end

    test "create a document", %{conn: conn, org: org} do
      payload = %{"document" => %{"title" => "My awesome book"}}
      conn = post(conn, document_path(conn, :create, org, payload))

      last_document = Query.first(Document) |> Repo.one!()

      assert redirected_to(conn, 302) =~
               document_page_path(conn, :show, org, last_document.main_page_id)
    end
  end

  describe "document visibility" do
    setup do
      workspace = insert_pied_piper!(:full)

      conn =
        build_conn()
        |> assign(:current_member, workspace.gilfoyle)
        |> assign(:current_account, workspace.gilfoyle.account)
        |> assign(:current_organization, workspace.organization)

      {:ok, conn: conn, workspace: workspace}
    end

    test "a document shared with everyone can be seen by anyone in the organization", %{
      conn: conn,
      workspace: workspace
    } do
      Documents.create_document(workspace.richard, nil, %{title: "Open doc"})
      conn = get(conn, document_path(conn, :index, workspace.organization))
      assert html_response(conn, 200) =~ "Open doc"
    end

    test "a document shared with a specific team can be seen by a member in this team", %{
      conn: conn,
      workspace: workspace
    } do
      Documents.create_document(workspace.richard, workspace.tech_team, %{
        title: "tech doc"
      })

      conn = get(conn, document_path(conn, :index, workspace.organization))
      assert html_response(conn, 200) =~ "tech doc"
    end

    test "a document shared with a specific team is not accessible by a member outside this team",
         %{conn: conn, workspace: workspace} do
      Documents.create_document(workspace.richard, workspace.management_team, %{
        title: "management doc"
      })

      conn = get(conn, document_path(conn, :index, workspace.organization))
      refute html_response(conn, 200) =~ "management doc"
    end

    test "a document in an organization is not accessible from another organization", %{
      conn: conn,
      workspace: workspace
    } do
      workspace2 = insert_hooli!()

      Documents.create_document(workspace2.gavin, nil, %{
        title: "other workspace doc"
      })

      conn = get(conn, document_path(conn, :index, workspace.organization))
      refute html_response(conn, 200) =~ "other workspace doc"
    end
  end
end
