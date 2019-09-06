defmodule PalapaWeb.MemberControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Access.GlobalId

  describe "as regular member" do
    setup do
      workspace = insert_pied_piper!()
      member = workspace.gilfoyle
      conn = login(member)

      {:ok, conn: conn, member: member, org: member.organization, workspace: workspace}
    end

    test "list all members in the organization", %{conn: conn, org: org} do
      conn = get(conn, member_path(conn, :index, org))
      assert html_response(conn, 200) =~ "Bertram Gilfoyle"
    end

    test "list members in a specific team", %{conn: conn, org: org, workspace: workspace} do
      conn = get(conn, member_path(conn, :index, org, team_id: workspace.tech_team.id))
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
      Palapa.Organizations.create_personal_information(member, %{
        label: "email",
        value: "bertram.gilfoyle@piedpiper.com"
      })

      Palapa.Organizations.create_personal_information(member, %{
        label: "address",
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
      workspace: workspace
    } do
      Palapa.Organizations.create_personal_information(workspace.jared, %{
        type: :email,
        value: "jared.dunn@piedpiper.com"
      })

      Palapa.Organizations.create_personal_information(workspace.jared, %{
        type: :address,
        value: "The basement",
        private: true
      })

      conn = get(conn, member_path(conn, :show, org, workspace.jared))
      assert html_response(conn, 200) =~ "jared.dunn@piedpiper.com"
      refute html_response(conn, 200) =~ "The basement"
    end

    test "the member can see private informations that are shared with him", %{
      conn: conn,
      org: org,
      member: member,
      workspace: workspace
    } do
      {:ok, _} =
        Palapa.Organizations.create_personal_information(workspace.jared, %{
          "label" => "skype",
          "value" => "mister.jared"
        })

      {:ok, _} =
        Palapa.Organizations.create_personal_information(workspace.jared, %{
          "label" => "email",
          "value" => "jared.dunn@piedpiper.com",
          "private" => true,
          "visibilities" => [to_string(GlobalId.create("palapa", member))]
        })

      {:ok, _} =
        Palapa.Organizations.create_personal_information(workspace.jared, %{
          "label" => "github",
          "value" => "jared-knows-code",
          "private" => true,
          "visibilities" => [to_string(GlobalId.create("palapa", workspace.tech_team))]
        })

      {:ok, _} =
        Palapa.Organizations.create_personal_information(workspace.jared, %{
          "label" => "address",
          "value" => "The basement",
          "private" => true
        })

      conn = get(conn, member_path(conn, :show, org, workspace.jared))

      assert html_response(conn, 200) =~ "mister.jared"
      assert html_response(conn, 200) =~ "jared.dunn@piedpiper.com"
      assert html_response(conn, 200) =~ "jared-knows-code"
      refute html_response(conn, 200) =~ "The basement"
    end
  end

  describe "as admin" do
    setup do
      workspace = insert_pied_piper!()
      admin = workspace.jared

      conn = login(admin)

      {:ok, conn: conn, org: workspace.organization}
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
      workspace = insert_pied_piper!()
      owner = workspace.richard

      conn = login(owner)

      {:ok, conn: conn, org: workspace.organization}
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
