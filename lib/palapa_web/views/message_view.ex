defmodule PalapaWeb.MessageView do
  use PalapaWeb, :view

  alias Palapa.RichText

  @excerpt_length 400

  def excerpt(content) when is_nil(content), do: nil

  def excerpt(content) do
    html_content = RichText.to_html(content)

    first_words =
      html_content
      |> HtmlSanitizeEx.Scrubber.scrub(PalapaWeb.MessageScrubber)
      |> strip_html_tags()
      |> String.slice(0..@excerpt_length)

    if String.length(html_content) > @excerpt_length do
      first_words <> "…"
    else
      first_words
    end
  end

  def strip_html_tags(content) when is_nil(content), do: ""

  def strip_html_tags(content) do
    content
    |> String.replace(~r/<br ?\/?>/, " ")
    |> String.replace("</li>", ", ")
    |> String.replace(~r/<.*?>/, " ")
    |> String.replace("&nbsp;", "")
  end

  def message_teams_tags(message) do
    teams = message.teams

    if Enum.any?(teams) do
      content_tag :div, class: "flex flex-wrap" do
        Enum.map(teams, fn team ->
          Helpers.team_tag(team)
        end)
      end
    end
  end

  def message_blank?(message) do
    is_nil(message.content)
  end
end
