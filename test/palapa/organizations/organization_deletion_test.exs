defmodule Palapa.OrganizationDeletionTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Organizations

  setup do
    pied_piper = insert_pied_piper!()
    hooli = insert_hooli!()

    %{
      pied_piper: pied_piper,
      hooli: hooli
    }
  end

  test "Orgs list when account is not an owner", %{
    pied_piper: pied_piper
  } do
    assert [] ==
             Organizations.organizations_to_delete_when_deleting_account(
               pied_piper.gilfoyle.account
             )
             |> Repo.all()
  end

  test "Orgs list when account is the only owner", %{
    pied_piper: pied_piper
  } do
    orgs_ids =
      Organizations.organizations_to_delete_when_deleting_account(pied_piper.richard.account)
      |> Repo.all()
      |> Enum.map(& &1.id)

    assert [pied_piper.organization.id] == orgs_ids
  end

  test "Orgs list when multiple owners", %{
    pied_piper: pied_piper,
    hooli: hooli
  } do
    # We make Gavin the second owner of Pied Piper
    Organizations.create_member(%{
      organization_id: pied_piper.organization.id,
      account_id: hooli.gavin.account.id,
      role: :owner
    })

    richard_orgs_ids =
      Organizations.organizations_to_delete_when_deleting_account(pied_piper.richard.account)
      |> Repo.all()
      |> Enum.map(& &1.id)

    assert [] == richard_orgs_ids

    gavin_orgs_ids =
      Organizations.organizations_to_delete_when_deleting_account(hooli.gavin.account)
      |> Repo.all()
      |> Enum.map(& &1.id)

    assert [hooli.organization.id] == gavin_orgs_ids
  end
end
