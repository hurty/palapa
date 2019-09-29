defmodule PalapaWeb.MemberView do
  use PalapaWeb, :view

  def organization_members(organization) do
    Palapa.Organizations.list_members(organization)
    |> Enum.map(fn m -> {m.account.name, m.id} end)
  end
end
