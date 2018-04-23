defmodule PalapaWeb.MemberView do
  use PalapaWeb, :view

  def organization_members(organization) do
    Palapa.Organizations.list_members(organization)
    |> Enum.map(fn m -> {m.name, m.id} end)
  end

  def organization_members_autocomplete(organization) do
    members = Palapa.Organizations.list_members(organization)

    content_tag(
      :ul,
      class: "autocomplete hidden",
      "data-target": "editor.autocompleteList"
    ) do
      for member <- members do
        content_tag(
          :li,
          member.name,
          class: "autocomplete__choice",
          "data-target": "editor.autocompleteChoice",
          "data-action": "mouseover->editor#selectAutocompleteChoice",
          "data-member-name": member.name,
          "data-member-id": member.id
        )
      end
    end
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
