defmodule PalapaWeb.MessageView do
  use PalapaWeb, :view

  @excerpt_length 380

  def excerpt(content) do
    first_words =
      content
      |> strip_html_tags()
      |> String.slice(0..@excerpt_length)

    if String.length(content) > @excerpt_length do
      first_words <> "…"
    else
      first_words
    end
  end

  def strip_html_tags(content) when is_nil(content), do: ""

  def strip_html_tags(content) do
    content
    |> String.replace(~r/<.*?>/, "")
    |> String.replace("&nbsp;", "")
  end

  def message_teams_tags(conn, message) do
    teams = message.teams

    if Enum.any?(teams) do
      content_tag :div, class: "flex flex-wrap" do
        Enum.map(teams, fn team ->
          PalapaWeb.TeamView.team_tag(conn, team)
        end)
      end
    end
  end

  def more_than_a_week_old?(message) do
    Timex.now()
    |> Timex.shift(days: -7)
    |> Timex.beginning_of_day()
    |> Timex.after?(message.inserted_at)
  end
end
