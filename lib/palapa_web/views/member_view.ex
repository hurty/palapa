defmodule PalapaWeb.MemberView do
  use PalapaWeb, :view
  alias Phoenix.HTML

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

  def account_time(account) do
    timezone = Map.get(account, :timezone) || "UTC"
    locale = Map.get(account, :locale) || "en"
    format = "{h24}:{m}"

    datetime =
      Timex.now()
      |> Timex.Timezone.convert(timezone)
      |> Timex.lformat!(format, locale)

    HTML.Tag.content_tag(:time, datetime)
  end
end
