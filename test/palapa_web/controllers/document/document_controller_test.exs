defmodule PalapaWeb.Document.DocumentControllerTest do
  use PalapaWeb.ConnCase

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
end
