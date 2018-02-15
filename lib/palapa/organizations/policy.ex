defmodule Palapa.Organizations.Policy do
  @behaviour Bodyguard.Policy

  alias Palapa.Organizations.Member

  # Owner can do anything
  def authorize(_, %Member{role: :owner}, _), do: true

  # Anybody can see the list of members within an organization
  def authorize(:list_members, %Member{}, _), do: true

  # Anybody can see another user in the same organization
  def authorize(:show_member, %Member{}, _), do: true

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
