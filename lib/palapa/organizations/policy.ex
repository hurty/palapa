defmodule Palapa.Organizations.Policy do
  use Palapa.Policy

  # Owner can do anything
  def authorize(_, %Member{role: :owner}, _), do: true

  # Anybody can see the list of members within an organization
  def authorize(:list_members, %Member{}, _), do: true

  # Anybody can see another user in the same organization
  def authorize(:show_member, %Member{}, _), do: true

  def authorize(:edit_member, %Member{}, _), do: true

  def authorize(:create_member_information, %Member{} = member, target_member) do
    member.id == target_member.id
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
