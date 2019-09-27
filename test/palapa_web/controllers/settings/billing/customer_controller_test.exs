defmodule PalapaWeb.Settings.Billing.CustomerControllerTest do
  use PalapaWeb.ConnCase

  describe "as owner" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.richard)
      {:ok, conn: conn, workspace: workspace}
    end

    test "an owner can access the billing settings", %{conn: conn, workspace: workspace} do
      conn = get(conn, Routes.settings_customer_path(conn, :show, workspace.organization))
      assert html_response(conn, 200) =~ "Billing overview"
    end
  end

  describe "as member" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.gilfoyle)
      {:ok, conn: conn, workspace: workspace}
    end

    test "a member cannot access the billing settings", %{conn: conn, workspace: workspace} do
      conn = get(conn, Routes.settings_customer_path(conn, :show, workspace.organization))
      assert html_response(conn, 403)
    end
  end
end
