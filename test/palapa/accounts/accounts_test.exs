defmodule Palapa.AccountsTest do
  use Palapa.DataCase

  alias Palapa.Accounts

  describe "users" do
    alias Palapa.Accounts.User

    @valid_attrs %{email: "some@email.com", name: "some name", password: "somePassword"}
    @update_attrs %{email: "some_updated@email.com", name: "some updated name", password: "someUpdatedPassword"}
    @invalid_attrs %{email: nil, name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      first_user = Accounts.list_users() |> List.first
      assert first_user.id  == user.id
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      fetched_user = Accounts.get_user!(user.id)
      assert fetched_user.id == user.id
    end

    test "get_user_by_email/1 returns the user with the given address" do
      user = user_fixture()
      fetched_user = Accounts.get_user_by_email(user.email)
      assert fetched_user.id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some@email.com"
      assert user.name == "some name"
      refute user.password_hash == nil
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some_updated@email.com"
      assert user.name == "some updated name"
      refute user.password_hash == nil
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "organizations" do
    alias Palapa.Accounts.Organization

    @valid_attrs %{name: "Hooli"}
    @update_attrs %{name: "Pied Piper"}
    @invalid_attrs %{name: nil}

    def organization_fixture(attrs \\ %{}) do
      {:ok, organization} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_organization()

      organization
    end

    test "list_organizations/0 returns all organizations" do
      organization = organization_fixture()
      assert Accounts.list_organizations() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Accounts.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      assert {:ok, %Organization{} = organization} = Accounts.create_organization(@valid_attrs)
      assert organization.name == "Hooli"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()
      assert {:ok, organization} = Accounts.update_organization(organization, @update_attrs)
      assert %Organization{} = organization
      assert organization.name == "Pied Piper"
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_organization(organization, @invalid_attrs)
      assert organization == Accounts.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Accounts.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Accounts.change_organization(organization)
    end
  end
end
