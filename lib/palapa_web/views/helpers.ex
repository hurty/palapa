defmodule PalapaWeb.Helpers do
  import Phoenix.HTML.Tag
  alias PalapaWeb.Router.Helpers, as: Routes
  alias PalapaWeb.Endpoint

  def get_timezone(conn) do
    Map.get(conn.assigns.current_account, :timezone) || "UTC"
  end

  def get_locale() do
    Gettext.get_locale(Palapa.Gettext)
  end

  def auto_format_datetime(_conn, datetime) when is_nil(datetime), do: nil

  def auto_format_datetime(conn, datetime) do
    more_than_a_week_old? =
      DateTime.utc_now()
      |> Timex.shift(days: -7)
      |> Timex.beginning_of_day()
      |> Timex.after?(datetime)

    short_format = "{WDshort} {D} {Mfull} {YYYY}"
    complete_format = "{WDshort} {D} {Mfull} {YYYY}, {h24}:{m} UTC{Z:}"

    datetime =
      if conn do
        datetime |> Timex.Timezone.convert(get_timezone(conn))
      else
        datetime
      end

    short_datetime =
      if(
        more_than_a_week_old?,
        do: Timex.lformat!(datetime, short_format, get_locale()),
        else: Timex.from_now(datetime, get_locale())
      )

    complete_datetime = datetime |> Timex.lformat!(complete_format, get_locale())

    content_tag(:span, short_datetime, title: complete_datetime)
  end

  def format_date(_conn, datetime) when is_nil(datetime), do: nil

  def format_date(conn, datetime) do
    short_format = "{Mfull} {D}, {YYYY}"

    datetime =
      if conn do
        datetime |> Timex.Timezone.convert(get_timezone(conn))
      else
        datetime
      end

    Timex.lformat!(datetime, short_format, get_locale())
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
    format = "{h24}:{m}"

    datetime =
      DateTime.utc_now()
      |> Timex.Timezone.convert(timezone)
      |> Timex.lformat!(format, get_locale())

    content_tag(:time, datetime)
  end

  def team_tag(team) do
    content_tag(
      :a,
      team.name,
      href: Routes.member_path(Endpoint, :index, team.organization_id, team_id: team),
      class: "tag tag-team"
    )
  end

  def team_checked?(changeset, team) do
    teams = Ecto.Changeset.get_field(changeset, :teams)
    teams && team.id in Enum.map(teams, & &1.id)
  end

  def rich_text_editor(form, field, organization, options \\ []) do
    attachments_url = Routes.attachment_url(Endpoint, :create, organization)
    Palapa.RichText.Helpers.rich_text_editor(form, field, attachments_url, options)
  end

  def auto_active_tab(navigation_value, tab_value) do
    "tab" <> if navigation_value == tab_value, do: " tab--active", else: ""
  end

  def countries_list() do
    countries =
      Countries.all()
      |> Enum.map(fn country -> country.name end)
      |> Enum.sort()

    [[key: "", value: ""] | countries]
  end

  def format_money(amount) do
    Money.new(amount, :EUR)
    |> Money.to_string()
  end

  @sizes ["Bytes", "KB", "MB", "GB", "TB", "PB"]
  def human_filesize(size_in_bytes) when is_binary(size_in_bytes) do
    size_in_bytes
    |> String.to_integer()
    |> human_filesize()
  end

  def human_filesize(size_in_bytes) when is_integer(size_in_bytes) do
    case size_in_bytes do
      nil ->
        nil

      0 ->
        "0 Byte"

      1 ->
        "1 Byte"

      _ ->
        try do
          exp =
            (:math.log(size_in_bytes) / :math.log(1000))
            |> Float.floor()
            |> round

          humanSize =
            (size_in_bytes / :math.pow(1000, exp))
            |> Float.ceil(2)

          "#{humanSize} #{Enum.at(@sizes, exp)}"
        rescue
          _ -> "Size unknown"
        end
    end
  end
end
