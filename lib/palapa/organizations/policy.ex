defmodule Palapa.Organizations.Policy do
  use Palapa.Policy
  alias Palapa.Organizations.PersonalInformation

  def authorize(:update_organization, %Member{} = member, _) do
    member.role == :owner
  end

  # Anybody can see the list of members within an organization
  def authorize(:list_members, %Member{}, _), do: true

  # Anybody can see another user in the same organization
  def authorize(:show_member, %Member{}, _), do: true

  def authorize(:edit_member, %Member{}, _), do: true

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
