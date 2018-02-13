defmodule Palapa.OrganizationsTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Organizations
  alias Palapa.Organizations.Organization

  test "list/1" do
    insert!(:organization, name: "one")
    insert!(:organization, name: "two")

    organizations = Organizations.list()
    assert Enum.count(organizations) == 2
    assert Enum.at(organizations, 0).name == "one"
    assert Enum.at(organizations, 1).name == "two"
  end

  test "get!/1 returns the organization with given id" do
    organization = insert!(:organization)
    assert Organizations.get!(organization.id) == organization
  end

  test "create/1 with valid data creates a organization" do
    assert {:ok, %Organization{} = organization} = Organizations.create(%{name: "Hooli"})

    assert organization.name == "Hooli"
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Organizations.create(%{name: ""})
  end

  test "update/2 with valid data updates the organization" do
    organization = insert!(:organization)

    assert {:ok, %Organization{} = organization} =
             Organizations.update(organization, %{name: "Hooli"})

    assert organization.name == "Hooli"
  end

  test "update/2 with invalid data returns error changeset" do
    organization = insert!(:organization)
    assert {:error, %Ecto.Changeset{}} = Organizations.update(organization, %{name: ""})
  end

  test "delete/1" do
    organization = insert!(:organization)
    assert {:ok, %Organization{}} = Organizations.delete(organization)

    assert_raise Ecto.NoResultsError, fn ->
      Organizations.get!(organization.id)
    end
  end

  test "change/1 returns a organization changeset" do
    organization = insert!(:organization)
    assert %Ecto.Changeset{} = Organizations.change(organization)
  end
end
