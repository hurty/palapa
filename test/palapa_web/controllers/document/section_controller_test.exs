defmodule PalapaWeb.Document.SectionControllerTest do
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

    test "create section", %{conn: conn, org: org, document: document} do
      assert 1 == Ecto.assoc(document, :sections) |> Repo.count()

      conn =
        post(
          conn,
          document_section_path(conn, :create, org, document, %{
            "section" => %{"title" => "first section"}
          })
        )

      assert html_response(conn, 200) =~ "first section"
      assert 2 == Ecto.assoc(document, :sections) |> Repo.count()
    end

    test "update section", %{conn: conn, org: org, member: member, document: document} do
      {:ok, section} = Documents.create_section(document, member, %{"title" => "first section"})

      conn =
        patch(
          conn,
          document_section_path(conn, :update, org, section, %{
            "section" => %{"title" => "1st section"}
          })
        )

      assert response(conn, 200)

      section = Repo.reload(section)
      assert "1st section" == section.title
    end

    test "delete section", %{conn: conn, org: org, member: member, document: document} do
      {:ok, section} = Documents.create_section(document, member, %{"title" => "first section"})

      conn =
        delete(
          conn,
          document_section_path(conn, :delete, org, section,
            current_page_id: Documents.get_first_page(document)
          )
        )

      assert redirected_to(conn, 302) =~
               document_page_path(conn, :show, org, Documents.get_first_page(document))

      section = Repo.reload(section)

      assert section.deleted_at
    end
  end

  # TODO: Test section visibility
end
