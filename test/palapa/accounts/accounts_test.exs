defmodule Palapa.AccountsTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Accounts
  alias Palapa.Accounts.{Organization, User, Team, TeamUser}

  describe "organizations" do
    test "list_organizations/0" do
      insert!(:organization, name: "one")
      insert!(:organization, name: "two")

      organizations = Accounts.list_organizations()
      assert Enum.count(organizations) == 2
      assert Enum.at(organizations, 0).name == "one"
      assert Enum.at(organizations, 1).name == "two"
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = insert!(:organization)
      assert Accounts.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      assert {:ok, %Organization{} = organization} =
               Accounts.create_organization(%{name: "Hooli"})

      assert organization.name == "Hooli"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_organization(%{name: ""})
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = insert!(:organization)

      assert {:ok, %Organization{} = organization} =
               Accounts.update_organization(organization, %{name: "Hooli"})

      assert organization.name == "Hooli"
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = insert!(:organization)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_organization(organization, %{name: ""})
    end

    test "delete_organization/1" do
      organization = insert!(:organization)
      assert {:ok, %Organization{}} = Accounts.delete_organization(organization)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_organization!(organization.id)
      end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = insert!(:organization)
      assert %Ecto.Changeset{} = Accounts.change_organization(organization)
    end
  end

  describe "users" do
    test "get_user!/1 returns the user with given id" do
      user = insert!(:member)
      fetched_user = Accounts.get_user!(user.id)
      assert fetched_user.email == user.email
    end

    test "get_user_by/1 returns the user with the given email address" do
      user = insert!(:member)
      fetched_user = %User{} = Accounts.get_user_by(email: "bertram.gilfoyle@piedpiper.com")
      assert fetched_user.id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} =
               Accounts.create_user(%{name: "Gavin Belson", email: "gavin.belson@hooli.com"})

      assert user.name == "Gavin Belson"
      assert user.email == "gavin.belson@hooli.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{name: "Gavin Belson", email: ""})
    end

    test "update_user/2 with valid data updates the user" do
      user = insert!(:member)

      assert {:ok, %User{} = user} =
               Accounts.update_user(user, %{name: "Big Head", email: "big.head@hooli.com"})

      assert user.name == "Big Head"
      assert user.email == "big.head@hooli.com"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert!(:member)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, %{name: "Big Head", email: ""})
    end

    test "delete_user/1 deletes the user" do
      user = insert!(:member)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert!(:member)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "teams" do
    test "create_team/2 with valid data creates the team" do
      organization = insert!(:organization)

      assert {:ok, %Team{} = team} =
               Accounts.create_team(organization, %{
                 name: "Sales",
                 description: "The serious sales department"
               })

      assert team.name == "Sales"
      assert team.description == "The serious sales department"
    end

    test "create_team/2 with invalid data returns error changeset" do
      organization = insert!(:organization)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_team(organization, %{name: ""})
    end

    test "change_team/1 returns a changeset" do
      team = insert!(:team)
      assert %Ecto.Changeset{} = Accounts.change_team(team)
    end

    test "update_team/2 with valid data updates the team" do
      team = insert!(:team)

      assert {:ok, %Team{} = team} =
               Accounts.update_team(team, %{name: "New Team", description: "A super new one"})

      assert team.name == "New Team"
      assert team.description == "A super new one"
    end

    test "update_team/2 with invalid data returns an error changeset" do
      team = insert!(:team)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_team(team, %{name: ""})
    end

    test "delete_team/1" do
      team = insert!(:team)
      assert {:ok, %Team{}} = Accounts.delete_team(team)
    end

    test "list_teams/2 returns teams within the given organization" do
      organization = insert!(:organization)
      insert!(:team, organization: organization, name: "Engineering")
      insert!(:team, organization: organization, name: "Sales")

      [team1, team2] = Accounts.list_teams(organization)
      assert team1.name == "Engineering"
      assert team2.name == "Sales"
    end

    test "add_user_to_team/2" do
      team = insert!(:team)
      user = insert!(:member, organization: team.organization)

      assert {:ok, %Team{}} = Accounts.add_user_to_team(user, team)
      assert 1 == Repo.aggregate(TeamUser, :count, :user_id)
    end

    test "add_user_to_team/2 multiple times fails" do
      team = insert!(:team)
      user = insert!(:member, organization: team.organization)

      {:ok, %Team{}} = Accounts.add_user_to_team(user, team)
      assert {:error, %Ecto.Changeset{}} = Accounts.add_user_to_team(user, team)
      assert 1 == Repo.aggregate(TeamUser, :count, :user_id)
    end

    test "add_user_to_team/2 increments the team users count" do
      team = insert!(:team)
      user = insert!(:member, organization: team.organization)

      {:ok, %Team{} = team} = Accounts.add_user_to_team(user, team)
      assert 1 == team.users_count
    end

    test "remove_user_from_team/2" do
      user = insert!(:member)
      team = insert!(:team, users: [user])

      assert {:ok, %Team{}} = Accounts.remove_user_from_team(user, team)
    end

    test "remove_user_from_team/2 decrements the team users count" do
      user = insert!(:member)
      team = insert!(:team, users: [user], users_count: 1)

      assert {:ok, %Team{} = updated_team} = Accounts.remove_user_from_team(user, team)
      assert 0 == updated_team.users_count
    end

    test "user_in_team?/2 returns true if the user is a team member" do
      user = insert!(:member)
      team = insert!(:team, users: [user])

      assert Accounts.user_in_team?(user, team)
    end

    test "user_in_team?/2 returns false if the user is not a team member" do
      user = insert!(:member)
      team = insert!(:team, users: [])

      refute Accounts.user_in_team?(user, team)
    end
  end
end
