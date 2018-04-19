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

      {:ok, conn: conn, member: member}
    end

    test "list all members in the organization", %{conn: conn} do
      conn = get(conn, member_path(conn, :index))
      assert html_response(conn, 200) =~ "Bertram Gilfoyle"
    end

    test "list members in a specific team", %{conn: conn} do
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

      conn = get(conn, member_path(conn, :index, team_id: tech_team.id))
      assert html_response(conn, 200) =~ "Richard"
      assert html_response(conn, 200) =~ "Gilfoyle"
      refute html_response(conn, 200) =~ "Jared"
    end

    test "regular member cannot see the 'add people' link", %{conn: conn} do
      conn = get(conn, member_path(conn, :index))
      refute html_response(conn, 200) =~ "Invite people"
    end

    test "regular member cannot see 'the create a team' link", %{conn: conn} do
      conn = get(conn, member_path(conn, :index))
      refute html_response(conn, 200) =~ "Create a team"
    end

    test "show member profile", %{conn: conn} do
      conn = get(conn, member_path(conn, :show, conn.assigns.current_member))
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

      {:ok, conn: conn, member: member}
    end

    test "admins see the 'add people' link", %{conn: conn} do
      conn = get(conn, member_path(conn, :index))
      assert html_response(conn, 200) =~ "Invite people"
    end

    test "admins see 'the create a team' link", %{conn: conn} do
      conn = get(conn, member_path(conn, :index))
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

      {:ok, conn: conn, member: member}
    end

    test "owners see the 'add people' link", %{conn: conn} do
      conn = get(conn, member_path(conn, :index))
      assert html_response(conn, 200) =~ "Invite people"
    end

    test "owners see 'the create a team' link", %{conn: conn} do
      conn = get(conn, member_path(conn, :index))
      assert html_response(conn, 200) =~ "Create a team"
    end
  end
end
