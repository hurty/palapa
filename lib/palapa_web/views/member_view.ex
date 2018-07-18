defmodule PalapaWeb.MemberView do
  use PalapaWeb, :view

  def organization_members(organization) do
    Palapa.Organizations.list_members(organization)
    |> Enum.map(fn m -> {m.account.name, m.id} end)
  end

  def avatar(account, size \\ nil) do
    url = Palapa.Avatar.url({account.avatar, account}, :thumb)
    img_attributes = [alt: account.name, title: account.name]

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
