defmodule Palapa.Organizations.Policy do
  use Palapa.Policy

  alias Palapa.Organizations
  alias Palapa.Organizations.PersonalInformation

  def authorize(:access_organization, %Member{} = member, organization) do
    member.organization_id == organization.id && Organizations.active?(member)
  end

  def authorize(:leave_organization, %Member{} = member, organization) do
    owners_ids = Organizations.list_owners(organization) |> Enum.map(& &1.id)
    member.id not in owners_ids || Enum.count(owners_ids) > 1
  end

  def authorize(:update_organization, %Member{} = member, _) do
    member.role in [:owner, :admin]
  end

  def authorize(:delete_organization, %Member{} = member, _) do
    member.role == :owner
  end

  # Anybody can see the list of members within an organization
  def authorize(:list_members, %Member{}, _), do: true

  # Anybody can see another user in the same organization
  def authorize(:show_member, %Member{}, _), do: true

  def authorize(:edit_member, %Member{} = author, member) do
    author.id == member.id
  end

  def authorize(:update_role, %Member{} = author, %{member: member, role: "member"}) do
    author.role == :owner ||
      (author.role == :admin && member.role in [:member, :admin] && member.id != author.id)
  end

  def authorize(:update_role, %Member{} = author, %{member: member, role: "admin"}) do
    author.role == :owner ||
      (author.role == :admin && member.role in [:member, :admin] && member.id != author.id)
  end

  def authorize(:update_role, %Member{} = author, %{member: member, role: "owner"}) do
    author.role == :owner && member.id != author.id
  end

  def authorize(:delete_member, %Member{} = member, %Member{} = target_member) do
    member.role in [:admin, :owner] && member.id != target_member.id
  end

  def authorize(
        :create_personal_information,
        %Member{} = member,
        %Member{} = target_member
      ) do
    member.id == target_member.id
  end

  def authorize(
        :update_personal_information,
        %Member{} = member,
        %PersonalInformation{} = personal_information
      ) do
    member.id == personal_information.member_id
  end

  def authorize(
        :delete_personal_information,
        %Member{} = member,
        %PersonalInformation{} = personal_information
      ) do
    member.id == personal_information.member_id || member.role in [:owner, :admin]
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
