defmodule PalapaWeb.MemberView do
  use PalapaWeb, :view
  alias Phoenix.HTML

  def organization_members(organization) do
    Palapa.Organizations.list_members(organization)
    |> Enum.map(fn m -> {m.account.name, m.id} end)
  end

  def avatar(account, size \\ :sm) do
    url = Palapa.Avatar.url({account.avatar, account}, :thumb, signed: true)

    classes =
      case size do
        :md -> "avatar avatar--md"
        :sm -> "avatar avatar--sm"
        :xs -> "avatar avatar--xs"
        _ -> "avatar avatar--sm"
      end

    title = account.name
    avatar_initials = initials(account.name)
    bg_color = avatar_color(account.name)

    if url do
      content_tag(:image, nil, class: classes, src: url)
    else
      content_tag(:span, avatar_initials,
        class: classes,
        style: "background-color: #{bg_color};",
        title: title,
        alt: title
      )
    end
  end

  # get color() {
  #   const codes = Array.from(this.name).map(s => s.codePointAt(0));
  #   const seed = codes.reduce(
  #     (value, code) => (value += code),
  #     6
  #   );
  #   return COLORS[seed % COLORS.length];
  # }

  @colors ~w(ea644f f6f3e1 a9c8bc 859c9a 454549 f28281 fbdfc7 f7d8a5 f8cc63 4b608d 7ea79f 6d9da9 ffa07a 8b7765)
          |> Enum.map(fn color -> "##{color}" end)

  defp avatar_color(text) do
    codes = to_charlist(text)

    seed =
      Enum.reduce(codes, String.length(text), fn code, acc ->
        code + acc
      end)

    Enum.at(@colors, rem(seed, length(@colors)))
  end

  defp initials(name) do
    name
    |> String.split(~r/\s+/)
    |> Enum.map(fn word -> String.at(word, 0) end)
    |> Enum.join()
    |> String.upcase()
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
