defmodule PalapaWeb.TeamControllerTest do
  use PalapaWeb.ConnCase
  import Ecto.Query
  alias Palapa.Repo

  describe "as owner" do
    setup do
      member = insert!(:owner)

      conn =
        build_conn()
        |> assign(:current_member, member)
        |> assign(:current_account, member.account)
        |> assign(:current_organization, member.organization)

      {:ok, conn: conn, member: member}
    end

    test "display the 'create a new team' form", %{conn: conn} do
      conn = get(conn, team_path(conn, :new))
      assert html_response(conn, 200) =~ ~r/Create a new team/
    end

    test "cannot create a team with a name that already exists", %{conn: conn} do
      insert!(:team, name: "Sales", organization: conn.assigns.current_organization)
      count_before = Repo.count("teams")
      conn = post(conn, team_path(conn, :create), %{"team" => %{"name" => "Sales"}})
      count_after = Repo.count("teams")

      assert html_response(conn, 200) =~ ~r/team already exist/
      assert count_after == count_before
    end

    test "cannot create a team without a name", %{conn: conn} do
      count_before = Repo.count("teams")
      conn = post(conn, team_path(conn, :create), %{"team" => %{"name" => ""}})
      count_after = Repo.count("teams")

      assert html_response(conn, 200)
      assert get_flash(conn, :error) =~ ~r/The team can't be created/
      assert count_after == count_before
    end

    test "create a team successfully", %{conn: conn} do
      team_member1 = insert!(:member, organization: conn.assigns.current_organization)
      team_member2 = insert!(:admin, organization: conn.assigns.current_organization)

      count_teams_before = Repo.count("teams")
      count_teams_members_before = count_team_members_records()

      conn =
        post(conn, team_path(conn, :create), %{
          "team" => %{
            "name" => "Sales",
            "members" => [team_member1.id, team_member2.id]
          }
        })

      count_teams_after = Repo.count("teams")
      count_teams_members_after = count_team_members_records()

      assert redirected_to(conn, 302) =~ member_path(conn, :index)
      assert count_teams_after == count_teams_before + 1
      assert count_teams_members_after == count_teams_members_before + 2
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

    test "display the 'create a new team' form", %{conn: conn} do
      conn = get(conn, team_path(conn, :new))
      assert html_response(conn, 200) =~ ~r/Create a new team/
    end

    test "create an empty team successfully", %{conn: conn} do
      count_teams_before = Repo.count("teams")

      conn =
        post(conn, team_path(conn, :create), %{
          "team" => %{
            "name" => "Sales"
          }
        })

      count_teams_after = Repo.count("teams")

      assert redirected_to(conn, 302) =~ member_path(conn, :index)
      assert count_teams_after == count_teams_before + 1
    end
  end

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

    test "regular members cannot access the team creation form", %{conn: conn} do
      conn = get(conn, team_path(conn, :new))
      assert html_response(conn, :forbidden)
    end
  end

  defp count_team_members_records do
    from(p in "teams_members", select: count(p.team_id)) |> Repo.one()
  end
end
