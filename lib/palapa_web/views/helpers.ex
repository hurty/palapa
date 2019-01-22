defmodule PalapaWeb.Helpers do
  alias Phoenix.HTML

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

    HTML.Tag.content_tag(:span, short_datetime, title: complete_datetime)
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

  def sanitize_html(text) do
    HtmlSanitizeEx.Scrubber.scrub(text, PalapaWeb.TrixScrubber)
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
end
