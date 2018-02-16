defmodule Palapa.TeamsTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Teams
  alias Palapa.Teams.{Team, TeamMember}

  test "create_team/2 with valid data creates the team" do
    organization = insert!(:organization)

    assert {:ok, %Team{}} = Teams.create(organization, %{name: "Sales"})
  end

  test "create_team/2 with invalid data returns error changeset" do
    organization = insert!(:organization)
    assert {:error, %Ecto.Changeset{}} = Teams.create(organization, %{name: ""})
  end

  test "change_team/1 returns a changeset" do
    team = insert!(:team)
    assert %Ecto.Changeset{} = Teams.change(team)
  end

  test "update_team/2 with valid data updates the team" do
    team = insert!(:team)

    assert {:ok, %Team{} = team} = Teams.update(team, %{name: "New Team"})
    assert team.name == "New Team"
  end

  test "update_team/2 with invalid data returns an error changeset" do
    team = insert!(:team)
    assert {:error, %Ecto.Changeset{}} = Teams.update(team, %{name: ""})
  end

  test "delete_team/1" do
    team = insert!(:team)
    assert {:ok, %Team{}} = Teams.delete(team)
  end

  test "list/2 returns teams within the given organization" do
    organization = insert!(:organization)
    insert!(:team, organization: organization, name: "Engineering")
    insert!(:team, organization: organization, name: "Sales")

    [team1, team2] = Teams.list(organization)
    assert team1.name == "Engineering"
    assert team2.name == "Sales"
  end

  test "add_member/2" do
    team = insert!(:team)
    member = insert!(:member, organization: team.organization)

    assert {:ok, %Team{}} = Teams.add_member(team, member)
    assert 1 == Repo.aggregate(TeamMember, :count, :member_id)
  end

  test "add_member/2 multiple times fails" do
    team = insert!(:team)
    member = insert!(:member, organization: team.organization)

    {:ok, %Team{}} = Teams.add_member(team, member)
    assert {:error, %Ecto.Changeset{}} = Teams.add_member(team, member)
    assert 1 == Repo.aggregate(TeamMember, :count, :member_id)
  end

  test "add_member/2 increments the team members count" do
    team = insert!(:team)
    member = insert!(:member, organization: team.organization)

    {:ok, %Team{} = team} = Teams.add_member(team, member)
    assert 1 == team.members_count
  end

  test "remove_member/2" do
    member = insert!(:member)
    team = insert!(:team, members: [member])

    assert {:ok, %Team{}} = Teams.remove_member(team, member)
  end

  test "remove_member/2 decrements the team members count" do
    member = insert!(:member)
    team = insert!(:team, members: [member], members_count: 1)

    assert {:ok, %Team{} = updated_team} = Teams.remove_member(team, member)
    assert 0 == updated_team.members_count
  end

  test "member?/2 returns true if the member is a team member" do
    member = insert!(:member)
    team = insert!(:team, members: [member])

    assert Teams.member?(team, member)
  end

  test "member?/2 returns false if the member is not a team member" do
    member = insert!(:member)
    team = insert!(:team, members: [])

    refute Teams.member?(team, member)
  end
end
