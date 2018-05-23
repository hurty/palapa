defmodule PalapaWeb.MemberView do
  use PalapaWeb, :view

  def organization_members(organization) do
    Palapa.Organizations.list_members(organization)
    |> Enum.map(fn m -> {m.name, m.id} end)
  end

  def avatar(member, size \\ nil) do
    url = Palapa.Avatar.url({member.avatar, member}, :thumb)
    img_attributes = [alt: member.name, title: member.name]

    img_attributes =
      if !url do
        Keyword.put(img_attributes, :"data-controller", "avatar")
      else
        img_attributes
      end

    img_attributes =
      case size do
        :medium -> Keyword.put(img_attributes, :class, "avatar avatar--md")
        :small -> Keyword.put(img_attributes, :class, "avatar avatar--sm")
        _ -> Keyword.put(img_attributes, :class, "avatar")
      end

    img_tag(
      url,
      img_attributes
    )
  end
end
