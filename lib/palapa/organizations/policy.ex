defmodule Palapa.Organizations.Policy do
  use Palapa.Policy
  alias Palapa.Organizations.MemberInformation

  # Anybody can see the list of members within an organization
  def authorize(:list_members, %Member{}, _), do: true

  # Anybody can see another user in the same organization
  def authorize(:show_member, %Member{}, _), do: true

  def authorize(:edit_member, %Member{}, _), do: true

  def authorize(
        :create_member_information,
        %Member{} = member,
        %Member{} = target_member
      ) do
    member.id == target_member.id
  end

  def authorize(
        :update_member_information,
        %Member{} = member,
        %MemberInformation{} = member_information
      ) do
    member.id == member_information.member_id
  end

  def authorize(
        :delete_member_information,
        %Member{} = member,
        %MemberInformation{} = member_information
      ) do
    member.id == member_information.member_id || member.role in [:owner, :admin]
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
