defmodule PalapaWeb.Settings.MemberLiveTest do
  use PalapaWeb.ConnCase
  import Phoenix.LiveViewTest, warn: false

  setup do
    workspace = insert_pied_piper!()
    conn = login(workspace.richard)
    {:ok, conn: conn, workspace: workspace}
  end

  test "initial rendering, disconnected state", %{conn: conn, workspace: workspace} do
    conn = get(conn, Routes.settings_member_path(conn, :index, workspace.organization))
    assert html_response(conn, 200) =~ "Workspace members"
  end
end
