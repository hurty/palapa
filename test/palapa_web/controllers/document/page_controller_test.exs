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

      {:ok, conn: conn, member: member, org: member.organization}
    end

    test "show page", %{conn: conn, org: org, member: member} do
      {:ok, document} = Documents.create_document(org, member, %{title: @doc_title})

      conn = get(conn, document_page_path(conn, :show, org, document.main_page_id))
      assert html_response(conn, 200) =~ @doc_title
    end

    test "edit page", %{conn: conn, org: org, member: member} do
      {:ok, document} = Documents.create_document(org, member, %{title: @doc_title})

      conn = get(conn, document_page_path(conn, :edit, org, document.main_page_id))
      assert html_response(conn, 200)
    end

    test "update page", %{conn: conn, org: org, member: member} do
      {:ok, document} = Documents.create_document(org, member, %{title: @doc_title})

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

    test "main page of a document can't be deleted", %{conn: conn, org: org, member: member} do
      {:ok, document} = Documents.create_document(org, member, %{title: @doc_title})

      assert_raise(Palapa.Documents.DeleteMainPageError, fn ->
        delete(
          conn,
          document_page_path(conn, :delete, org, document.main_page_id,
            current_page_id: document.main_page_id
          )
        )
      end)
    end

    test "delete page", %{conn: conn, org: org, member: member} do
      {:ok, document} = Documents.create_document(org, member, %{title: @doc_title})

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
end
