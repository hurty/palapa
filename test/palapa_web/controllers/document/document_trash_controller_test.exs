defmodule PalapaWeb.Document.DocumentTrashControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Documents

  describe "as regular member" do
    setup do
      workspace = insert_pied_piper!(:full)

      conn =
        build_conn()
        |> assign(:current_member, workspace.gilfoyle)
        |> assign(:current_account, workspace.gilfoyle.account)
        |> assign(:current_organization, workspace.organization)

      {:ok, conn: conn, workspace: workspace}
    end

    test "put a document in the trash", %{conn: conn, workspace: workspace} do
      {:ok, document} =
        Documents.create_document(workspace.richard, nil, %{
          title: "This is a styleguide for everyone"
        })

      conn =
        post(conn, Routes.document_trash_path(conn, :create, workspace.organization, document))

      assert redirected_to(conn, 302) =~
               Routes.document_path(conn, :index, workspace.organization)

      assert Phoenix.HTML.safe_to_string(get_flash(conn, :success)) =~ "has been deleted"
    end

    test "undo trash", %{conn: conn, workspace: workspace} do
      {:ok, document} =
        Documents.create_document(workspace.richard, nil, %{
          title: "This is a styleguide for everyone"
        })

      document = Documents.delete_document!(document, workspace.gilfoyle)

      conn =
        delete(conn, Routes.document_trash_path(conn, :delete, workspace.organization, document))

      assert redirected_to(conn, 302) =~
               Routes.document_path(conn, :index, workspace.organization)

      assert get_flash(conn, :success) =~ "has been restored"
    end
  end
end
