defmodule PalapaWeb.MemberControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Access.GlobalId

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

    test "the member can see all his informations, even private", %{
      conn: conn,
      org: org,
      member: member
    } do
      Palapa.Organizations.create_member_information(member, %{
        type: :email,
        value: "bertram.gilfoyle@piedpiper.com"
      })

      Palapa.Organizations.create_member_information(member, %{
        type: :address,
        value: "28 rue saint antoine 44000 Nantes",
        private: true
      })

      conn = get(conn, member_path(conn, :show, org, member))
      assert html_response(conn, 200) =~ "bertram.gilfoyle@piedpiper.com"
      assert html_response(conn, 200) =~ "28 rue saint antoine 44000 Nantes"
    end

    test "the member can see all public informations on another profile", %{
      conn: conn,
      org: org,
      member: member
    } do
      other_member = insert!(:admin, organization: member.organization)

      Palapa.Organizations.create_member_information(other_member, %{
        type: :email,
        value: "jared.dunn@piedpiper.com"
      })

      Palapa.Organizations.create_member_information(other_member, %{
        type: :address,
        value: "The basement",
        private: true
      })

      conn = get(conn, member_path(conn, :show, org, other_member))
      assert html_response(conn, 200) =~ "jared.dunn@piedpiper.com"
      refute html_response(conn, 200) =~ "The basement"
    end

    test "the member can see private informations that are shared with him", %{
      conn: conn,
      org: org,
      member: member
    } do
      jared = insert!(:admin, organization: member.organization)

      {:ok, _} =
        Palapa.Organizations.create_member_information(jared, %{
          "type" => :skype,
          "value" => "mister.jared"
        })

      {:ok, _} =
        Palapa.Organizations.create_member_information(jared, %{
          "type" => :email,
          "value" => "jared.dunn@piedpiper.com",
          "private" => true,
          "visibilities" => [to_string(GlobalId.create("palapa", member))]
        })

      tech_team =
        insert!(:team,
          organization: jared.organization,
          name: "Management",
          members: [member]
        )

      {:ok, _} =
        Palapa.Organizations.create_member_information(jared, %{
          "type" => :github,
          "value" => "jared-knows-code",
          "private" => true,
          "visibilities" => [to_string(GlobalId.create("palapa", tech_team))]
        })

      {:ok, _} =
        Palapa.Organizations.create_member_information(jared, %{
          "type" => :address,
          "value" => "The basement",
          "private" => true
        })

      conn = get(conn, member_path(conn, :show, org, jared))

      assert html_response(conn, 200) =~ "mister.jared"
      assert html_response(conn, 200) =~ "jared.dunn@piedpiper.com"
      assert html_response(conn, 200) =~ "jared-knows-code"
      refute html_response(conn, 200) =~ "The basement"
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
