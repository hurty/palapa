defmodule PalapaWeb.MemberControllerTest do
  use PalapaWeb.ConnCase

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

    test "list all members in the organization", %{conn: conn, org: org} do
      conn = get(conn, member_path(conn, :index, org))
      assert html_response(conn, 200) =~ "Bertram Gilfoyle"
    end

    test "list members in a specific team", %{conn: conn, org: org} do
      insert!(
        :team,
        name: "Management",
        organization: conn.assigns.current_organization,
        members: [insert!(:admin)]
      )

      tech_team =
        insert!(
          :team,
          name: "Tech",
          organization: conn.assigns.current_organization,
          members: [
            insert!(:owner),
            conn.assigns.current_member
          ]
        )

      conn = get(conn, member_path(conn, :index, org, team_id: tech_team.id))
      assert html_response(conn, 200) =~ "Richard"
      assert html_response(conn, 200) =~ "Gilfoyle"
      refute html_response(conn, 200) =~ "Jared"
    end

    test "regular member cannot see the 'add people' link", %{conn: conn, org: org} do
      conn = get(conn, member_path(conn, :index, org))
      refute html_response(conn, 200) =~ "Invite people"
    end

    test "regular member cannot see 'the create a team' link", %{
      conn: conn,
      org: org
    } do
      conn = get(conn, member_path(conn, :index, org))
      refute html_response(conn, 200) =~ "Create a team"
    end

    test "show member profile", %{conn: conn, org: org, member: member} do
      conn = get(conn, member_path(conn, :show, org, member))
      assert html_response(conn, 200) =~ "Bertram Gilfoyle"
    end
  end

  describe "as admin" do
    setup do
      member = insert!(:admin)

      conn =
        build_conn()
        |> assign(:current_member, member)
        |> assign(:current_account, member.account)
        |> assign(:current_organization, member.organization)

      {:ok, conn: conn, member: member, org: member.organization}
    end

    test "admins see the 'add people' link", %{conn: conn, org: org} do
      conn = get(conn, member_path(conn, :index, org))
      assert html_response(conn, 200) =~ "Invite people"
    end

    test "admins see 'the create a team' link", %{conn: conn, org: org} do
      conn = get(conn, member_path(conn, :index, org))
      assert html_response(conn, 200) =~ "Create a team"
    end
  end

  describe "as owner" do
    setup do
      member = insert!(:admin)

      conn =
        build_conn()
        |> assign(:current_member, member)
        |> assign(:current_account, member.account)
        |> assign(:current_organization, member.organization)

      {:ok, conn: conn, member: member, org: member.organization}
    end

    test "owners see the 'add people' link", %{conn: conn, org: org} do
      conn = get(conn, member_path(conn, :index, org))
      assert html_response(conn, 200) =~ "Invite people"
    end

    test "owners see 'the create a team' link", %{conn: conn, org: org} do
      conn = get(conn, member_path(conn, :index, org))
      assert html_response(conn, 200) =~ "Create a team"
    end
  end
end
