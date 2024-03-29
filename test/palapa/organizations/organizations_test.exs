defmodule Palapa.OrganizationsTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Organizations
  alias Palapa.Organizations.Organization

  test "get!/1 returns the organization with given id" do
    organization = insert!(:organization)
    assert Organizations.get!(organization.id) == organization
  end

  test "create/1 with valid data creates a organization" do
    owner = insert!(:jared)
    assert {:ok, %{organization: organization}} = Organizations.create(%{name: "Hooli"}, owner)

    assert organization.name == "Hooli"
  end

  test "create/1 with invalid data returns error changeset" do
    owner = insert!(:jared)

    assert {:error, :organization, %Ecto.Changeset{}, _} =
             Organizations.create(%{name: ""}, owner)
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

  test "change/1 returns a organization changeset" do
    organization = insert!(:organization)
    assert %Ecto.Changeset{} = Organizations.change(organization)
  end

  describe "organization deletion" do
    test "delete/1 marks an organization with no subscription as deleted" do
      owner = insert!(:owner)

      assert {:ok, %{organization: deleted_organization}} =
               Organizations.delete(owner.organization, owner)

      assert deleted_organization.deleted_at
    end
  end

  test "delete/1 marks an organization with subscription as deleted and plan Stripe subscription cancellation" do
    owner = insert!(:owner)
    insert!(:subscription, organization: owner.organization)

    assert {:ok, result} = Organizations.delete(owner.organization, owner)

    assert_enqueued(
      worker: Palapa.Billing.Workers.CancelSubscription,
      args: %{organization_id: owner.organization_id}
    )
  end
end
