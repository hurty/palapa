defmodule PalapaWeb.MemberView do
  use PalapaWeb, :view
  alias Phoenix.HTML

  def organization_members(organization) do
    Palapa.Organizations.list_members(organization)
    |> Enum.map(fn m -> {m.account.name, m.id} end)
  end

  def avatar(account, size \\ nil) do
    url = Palapa.Avatar.url({account.avatar, account}, :thumb, signed: true)
    img_attributes = [alt: account.name, title: account.name]

    img_attributes =
      if !url do
        Keyword.put(img_attributes, :"data-controller", "avatar")
      else
        img_attributes
      end

    img_attributes =
      case size do
        :medium -> Keyword.put(img_attributes, :class, "inline avatar avatar--md")
        :small -> Keyword.put(img_attributes, :class, "inline avatar avatar--sm")
        :xs -> Keyword.put(img_attributes, :class, "inline avatar avatar--xs")
        _ -> Keyword.put(img_attributes, :class, "inline avatar")
      end

    img_tag(
      url,
      img_attributes
    )
  end

  def account_time(account) do
    timezone = Map.get(account, :timezone) || "UTC"
    locale = Map.get(account, :locale) || "en"
    format = "{h24}:{m}"

    datetime =
      DateTime.utc_now()
      |> Timex.Timezone.convert(timezone)
      |> Timex.lformat!(format, locale)

    HTML.Tag.content_tag(:time, datetime)
  end
end
