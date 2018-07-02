defmodule PalapaWeb.Helpers do
  alias Phoenix.HTML

  def format_datetime(datetime, _account) when is_nil(datetime), do: nil

  def format_datetime(datetime, account) do
    more_than_a_week_old? =
      Timex.now()
      |> Timex.shift(days: -7)
      |> Timex.beginning_of_day()
      |> Timex.after?(datetime)

    timezone = Map.get(account, :timezone) || "UTC"
    locale = Map.get(account, :locale) || "en"
    short_format = "{WDshort} {D} {Mfull} {YYYY}, {h24}:{m}"
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

  def text_editor(organization, options \\ []) do
    editor_classes = "trix-content p-4 bg-white shadow-inner text-grey-darkest "

    editor_classes = editor_classes <> (options[:class] || "min-h-screen-1/2")

    HTML.Tag.content_tag :div,
      class: "border rounded",
      "data-controller": "editor",
      "data-editor-autocomplete-index": "0",
      "data-editor-members": members_for_autocomplete(organization) do
      [
        HTML.Tag.content_tag(
          :"trix-editor",
          nil,
          class: editor_classes,
          placeholder: options[:placeholder] || "Your message here...",
          input: options[:input] || "content",
          "data-target": options[:"data-target"] || ""
        ),
        HTML.Tag.content_tag(
          :ul,
          nil,
          class: "autocomplete hidden",
          "data-target": "editor.autocompleteList"
        )
      ]
    end
  end

  def members_for_autocomplete(organization) do
    Palapa.Organizations.list_members(organization)
    |> Enum.map(fn m -> %{"id" => m.id, "name" => m.name} end)
    |> Jason.encode!()
  end

  def sanitize_html(text) do
    HtmlSanitizeEx.Scrubber.scrub(text, PalapaWeb.TrixScrubber)
  end
end
