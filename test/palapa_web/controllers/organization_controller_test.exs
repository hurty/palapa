defmodule PalapaWeb.OrganizationControllerTest do
  use PalapaWeb.ConnCase
  use Bamboo.Test, shared: true

  setup do
    workspace = insert_pied_piper!()
    conn = login(workspace.richard)
    {:ok, conn: conn}
  end

  test "display the list of workspaces", %{conn: conn} do
    conn = get(conn, Routes.organization_path(conn, :index))
    assert html_response(conn, 200) =~ "workspaces"
  end
end
