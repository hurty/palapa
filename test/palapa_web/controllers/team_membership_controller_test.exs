defmodule PalapaWeb.TeamMembershipControllerTest do
  use PalapaWeb.ConnCase

  describe "as regular member" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.gilfoyle)

      {:ok, conn: conn, workspace: workspace}
    end

    test "regular members can join a public team", %{conn: conn, workspace: workspace} do
      public_team =
        insert!(:team, name: "General", private: false, organization: workspace.organization)

      conn =
        post(
          conn,
          Routes.team_team_membership_path(conn, :create, workspace.organization, public_team)
        )

      assert redirected_to(conn, 302) =~
               Routes.member_path(conn, :index, workspace.organization, %{
                 "team_id" => public_team.id
               })

      assert "You have joined the team \"General\"" == get_flash(conn, :success)
    end

    test "regular members cannot join a private team", %{conn: conn, workspace: workspace} do
      private_team =
        insert!(:team, name: "Private", private: true, organization: workspace.organization)

      conn =
        post(
          conn,
          Routes.team_team_membership_path(conn, :create, workspace.organization, private_team)
        )

      assert html_response(conn, :forbidden)
    end

    test "regular members can leave any team", %{conn: conn, workspace: workspace} do
      conn =
        delete(
          conn,
          Routes.team_team_membership_path(
            conn,
            :delete,
            workspace.organization,
            workspace.tech_team
          )
        )

      assert redirected_to(conn, 302) =~
               Routes.member_path(conn, :index, workspace.organization, %{
                 "team_id" => workspace.tech_team.id
               })

      assert "You have left the team \"Tech\"" == get_flash(conn, :success)
    end
  end

  describe "as admin" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.jared)

      {:ok, conn: conn, workspace: workspace}
    end

    test "an admin can join a private team", %{conn: conn, workspace: workspace} do
      private_team =
        insert!(:team, name: "Private", private: true, organization: workspace.organization)

      conn =
        post(
          conn,
          Routes.team_team_membership_path(conn, :create, workspace.organization, private_team)
        )

      assert redirected_to(conn, 302) =~
               Routes.member_path(conn, :index, workspace.organization, %{
                 "team_id" => private_team.id
               })

      assert "You have joined the team \"Private\"" == get_flash(conn, :success)
    end
  end

  describe "as owner" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.richard)

      {:ok, conn: conn, workspace: workspace}
    end

    test "the owner can join a private team", %{conn: conn, workspace: workspace} do
      private_team =
        insert!(:team, name: "Private", private: true, organization: workspace.organization)

      conn =
        post(
          conn,
          Routes.team_team_membership_path(conn, :create, workspace.organization, private_team)
        )

      assert redirected_to(conn, 302) =~
               Routes.member_path(conn, :index, workspace.organization, %{
                 "team_id" => private_team.id
               })

      assert "You have joined the team \"Private\"" == get_flash(conn, :success)
    end
  end
end
