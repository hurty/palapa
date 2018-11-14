defmodule PalapaWeb.Document.PageControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Documents

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
      {:ok, %{main_page: main_page}} =
        Documents.create_document(org, member, %{title: @doc_title})

      conn = get(conn, document_page_path(conn, :show, org, main_page))
      assert html_response(conn, 200) =~ @doc_title
    end

    test "edit page", %{conn: conn, org: org, member: member} do
      {:ok, %{main_page: main_page}} =
        Documents.create_document(org, member, %{title: @doc_title})

      conn = get(conn, document_page_path(conn, :edit, org, main_page))
      assert html_response(conn, 200)
    end

    test "update page", %{conn: conn, org: org, member: member} do
      {:ok, %{main_page: main_page}} =
        Documents.create_document(org, member, %{title: @doc_title})

      payload = %{"page" => %{"title" => "My awesome page", "body" => "updated page content"}}

      conn =
        patch(
          conn,
          document_page_path(conn, :update, org, main_page, payload)
        )

      assert redirected_to(conn, 302) =~ document_page_path(conn, :show, org, main_page)
      reloaded_page = Documents.get_page!(main_page.id)
      assert "updated page content" == reloaded_page.body
    end

    test "main page of a document can't be deleted", %{conn: conn, org: org, member: member} do
      {:ok, %{main_page: main_page}} =
        Documents.create_document(org, member, %{title: @doc_title})

      assert_raise(Palapa.Documents.DeleteMainPageError, fn ->
        delete(
          conn,
          document_page_path(conn, :delete, org, main_page, current_page_id: main_page.id)
        )
      end)
    end

    test "delete page", %{conn: conn, org: org, member: member} do
      {:ok, %{document: document, main_section: main_section}} =
        Documents.create_document(org, member, %{title: @doc_title})

      {:ok, page} = Documents.create_page(document, main_section, member, %{title: "new page"})

      conn =
        delete(
          conn,
          document_page_path(conn, :delete, org, page, current_page_id: page.id)
        )

      assert redirected_to(conn, 302)
    end
  end
end
