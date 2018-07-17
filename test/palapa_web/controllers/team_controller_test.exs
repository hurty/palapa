defmodule PalapaWeb.TeamControllerTest do
  use PalapaWeb.ConnCase
  import Ecto.Query
  alias Palapa.Teams
  alias Palapa.Repo

  describe "as regular member" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.gilfoyle)

      {:ok, conn: conn, workspace: workspace}
    end

    test "regular members cannot access the team creation form", %{
      conn: conn,
      workspace: workspace
    } do
      conn = get(conn, team_path(conn, :new, workspace.organization))
      assert html_response(conn, :forbidden)
    end

    test "regular members cannot create new team", %{conn: conn, workspace: workspace} do
      conn =
        post(conn, team_path(conn, :create, workspace.organization), %{
          "team" => %{
            "name" => "Sales"
          }
        })

      assert html_response(conn, :forbidden)
    end

    test "regular members cannot access the team edition form", %{
      conn: conn,
      workspace: workspace
    } do
      {:ok, team} = Teams.create(workspace.organization, %{name: "Sales"})
      conn = get(conn, team_path(conn, :edit, workspace.organization, team))
      assert html_response(conn, :forbidden)
    end

    test "regular members cannot update a team", %{
      conn: conn,
      workspace: workspace
    } do
      {:ok, team} = Teams.create(workspace.organization, %{name: "Sales"})

      conn =
        put(
          conn,
          team_path(conn, :update, workspace.organization, team, %{
            "team" => %{"name" => "Sales Dpt"}
          })
        )

      assert html_response(conn, :forbidden)
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

    test "display the 'create a team' form", %{conn: conn, org: org} do
      conn = get(conn, team_path(conn, :new, org))
      assert html_response(conn, 200) =~ ~r/New team/
    end

    test "create an empty team successfully", %{conn: conn, org: org} do
      count_teams_before = Repo.count("teams")

      conn =
        post(conn, team_path(conn, :create, org), %{
          "team" => %{
            "name" => "Sales"
          }
        })

      count_teams_after = Repo.count("teams")

      assert redirected_to(conn, 302) =~ member_path(conn, :index, org)
      assert count_teams_after == count_teams_before + 1
    end

    test "admin can access the team edition form", %{conn: conn, org: org} do
      {:ok, team} = Teams.create(org, %{name: "Sales"})
      conn = get(conn, team_path(conn, :edit, org, team))
      assert html_response(conn, :ok)
    end

    test "admin can update a team", %{conn: conn, org: org, member: member} do
      {:ok, team} = Teams.create(org, %{name: "Sales", private: false, members: []})

      conn =
        put(
          conn,
          team_path(conn, :update, org, team, %{
            "team" => %{"name" => "Sales Dpt", "private" => true, "members" => [member.id]}
          })
        )

      assert redirected_to(conn, 302) =~ member_path(conn, :index, org, team_id: team.id)
      team = Repo.reload(team) |> Repo.preload(:members)
      assert "Sales Dpt" == team.name
      assert team.private
      assert [member.id] == team.members |> Enum.map(fn m -> m.id end)
    end
  end

  describe "as owner" do
    setup do
      member = insert!(:owner)

      conn =
        build_conn()
        |> assign(:current_member, member)
        |> assign(:current_account, member.account)
        |> assign(:current_organization, member.organization)

      {:ok, conn: conn, member: member, org: member.organization}
    end

    test "display the 'new team' form", %{conn: conn, org: org} do
      conn = get(conn, team_path(conn, :new, org))
      assert html_response(conn, 200) =~ ~r/New team/
    end

    test "cannot create a team with a name that already exists", %{conn: conn, org: org} do
      insert!(:team, name: "Sales", organization: conn.assigns.current_organization)
      count_before = Repo.count("teams")
      conn = post(conn, team_path(conn, :create, org), %{"team" => %{"name" => "Sales"}})
      count_after = Repo.count("teams")

      assert html_response(conn, 200) =~ ~r/team already exist/
      assert count_after == count_before
    end

    test "cannot create a team without a name", %{conn: conn, org: org} do
      count_before = Repo.count("teams")
      conn = post(conn, team_path(conn, :create, org), %{"team" => %{"name" => ""}})
      count_after = Repo.count("teams")

      assert html_response(conn, 200)
      assert get_flash(conn, :error) =~ ~r/The team can't be created/
      assert count_after == count_before
    end

    test "create a team successfully", %{conn: conn, org: org} do
      team_member1 = insert!(:member, organization: org)
      team_member2 = insert!(:admin, organization: org)

      count_teams_before = Repo.count("teams")
      count_teams_members_before = count_team_members_records()

      conn =
        post(conn, team_path(conn, :create, org), %{
          "team" => %{
            "name" => "Sales",
            "members" => [team_member1.id, team_member2.id]
          }
        })

      count_teams_after = Repo.count("teams")
      count_teams_members_after = count_team_members_records()

      assert redirected_to(conn, 302) =~ member_path(conn, :index, org)
      assert count_teams_after == count_teams_before + 1
      assert count_teams_members_after == count_teams_members_before + 2
    end

    test "owner can access the team edition form", %{conn: conn, org: org} do
      {:ok, team} = Teams.create(org, %{name: "Sales"})
      conn = get(conn, team_path(conn, :edit, org, team))
      assert html_response(conn, :ok)
    end

    test "owner can update a team", %{conn: conn, org: org, member: member} do
      {:ok, team} = Teams.create(org, %{name: "Sales", private: false, members: []})

      conn =
        put(
          conn,
          team_path(conn, :update, org, team, %{
            "team" => %{"name" => "Sales Dpt", "private" => true, "members" => [member.id]}
          })
        )

      assert redirected_to(conn, 302) =~ member_path(conn, :index, org, team_id: team.id)
      team = Repo.reload(team) |> Repo.preload(:members)
      assert "Sales Dpt" == team.name
      assert team.private
      assert [member.id] == team.members |> Enum.map(fn m -> m.id end)
    end
  end

  defp count_team_members_records do
    from(p in "teams_members", select: count(p.team_id)) |> Repo.one()
  end
end
