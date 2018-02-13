defmodule Palapa.AccountsTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Accounts
  alias Palapa.Accounts.{Organization, User}

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
    test "get_user!/1 returns the user with given id within the given organization" do
      organization = insert!(:organization)
      user = insert!(:member)
      insert!(:membership, organization: organization, user: user, role: :owner)
      fetched_user = Accounts.get_user!(user.id, organization)
      assert fetched_user.email == user.email
    end

    test "get_user_by/1 returns the user with the given email address" do
      user = insert!(:member)
      fetched_user = %User{} = Accounts.get_user_by(email: "bertram.gilfoyle@piedpiper.com")
      assert fetched_user.id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} =
               Accounts.create_user(%{
                 name: "Gavin Belson",
                 email: "gavin.belson@hooli.com",
                 password: "password"
               })

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
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(User, user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert!(:member)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
