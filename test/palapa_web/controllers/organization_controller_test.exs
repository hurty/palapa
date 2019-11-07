defmodule PalapaWeb.OrganizationControllerTest do
  use PalapaWeb.ConnCase

  setup do
    workspace = insert_pied_piper!()
    conn = login(workspace.richard)
    {:ok, conn: conn, workspace: workspace}
  end

  test "display the list of active workspaces", %{conn: conn} do
    conn = get(conn, Routes.organization_path(conn, :index))
    assert html_response(conn, 200) =~ "Pied Piper"
  end

  test "deleted workspaces are not visible", %{conn: conn, workspace: workspace} do
    Palapa.Organizations.delete(workspace.organization, workspace.richard)
    conn = get(conn, Routes.organization_path(conn, :index))
    assert html_response(conn, 200) =~ "You are not a member of any workspace"
  end
end
