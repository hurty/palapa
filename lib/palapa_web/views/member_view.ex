defmodule PalapaWeb.MemberView do
  use PalapaWeb, :view

  def organization_members(organization) do
    Palapa.Organizations.list_members(organization)
    |> Enum.map(fn m -> {m.name, m.id} end)
  end

  def avatar(member) do
    url = Palapa.Avatar.url({member.avatar, member}, :thumb)
    img_tag(url, class: "avatar")
  end

  def avatar_medium(member) do
    url = Palapa.Avatar.url({member.avatar, member}, :thumb)
    img_tag(url, class: "avatar avatar--md")
  end

  def avatar_small(member) do
    url = Palapa.Avatar.url({member.avatar, member}, :thumb)
    img_tag(url, class: "avatar avatar--sm")
  end
end
