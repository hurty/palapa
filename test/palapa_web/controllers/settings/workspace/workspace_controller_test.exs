defmodule PalapaWeb.Settings.Workspace.WorkspaceControllerTest do
  use PalapaWeb.ConnCase

  describe "as admin" do
  end

  describe "as member" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.gilfoyle)
      {:ok, conn: conn, workspace: workspace}
    end

    test "a member cannot access workspace settings", %{conn: conn, workspace: workspace} do
      conn = get(conn, Routes.settings_workspace_path(conn, :show, workspace.organization))
      assert html_response(conn, :forbidden)
    end
  end
end
