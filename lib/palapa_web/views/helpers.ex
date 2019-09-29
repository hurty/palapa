defmodule PalapaWeb.Helpers do
  import Phoenix.HTML.Tag

  def auto_format_datetime(datetime, _account) when is_nil(datetime), do: nil

  def auto_format_datetime(datetime, account) do
    more_than_a_week_old? =
      DateTime.utc_now()
      |> Timex.shift(days: -7)
      |> Timex.beginning_of_day()
      |> Timex.after?(datetime)

    timezone = Map.get(account, :timezone) || "UTC"
    locale = Map.get(account, :locale) || "en"
    short_format = "{WDshort} {D} {Mfull} {YYYY}"
    complete_format = "{WDshort} {D} {Mfull} {YYYY}, {h24}:{m} UTC{Z:}"

    datetime = datetime |> Timex.Timezone.convert(timezone)

    short_datetime =
      if(
        more_than_a_week_old?,
        do: Timex.lformat!(datetime, short_format, locale),
        else: Timex.from_now(datetime)
      )

    complete_datetime = datetime |> Timex.lformat!(complete_format, locale)

    content_tag(:span, short_datetime, title: complete_datetime)
  end

  def format_date(datetime, _account) when is_nil(datetime), do: nil

  def format_date(datetime, account) do
    timezone = Map.get(account, :timezone) || "UTC"
    locale = Map.get(account, :locale) || "en"
    short_format = "{Mfull} {D}, {YYYY}"

    datetime = datetime |> Timex.Timezone.convert(timezone)

    Timex.lformat!(datetime, short_format, locale)
  end

  def members_for_autocomplete(organization) do
    Palapa.Organizations.list_members(organization)
    |> Enum.map(fn m -> %{"id" => m.id, "name" => m.account.name} end)
    |> Jason.encode!()
  end

  def truncate_string(string, length \\ 80)
  def truncate_string(string, _length) when is_nil(string), do: nil

  def truncate_string(string, length) do
    if String.length(string) > length do
      string
      |> String.slice(0..length)
      |> Kernel.<>("...")
    else
      string
    end
  end

  def dom_id(struct) do
    if Map.get(struct, :id) do
      resource_name =
        struct.__struct__
        |> Module.split()
        |> List.last()
        |> Macro.underscore()

      "#{resource_name}_#{struct.id}"
    end
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

    content_tag(:time, datetime)
  end
end
