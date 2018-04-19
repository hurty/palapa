defmodule PalapaWeb.MessageView do
  use PalapaWeb, :view

  def excerpt(content) do
    first_words =
      content
      |> strip_html_tags()
      |> String.slice(0..380)

    if first_words != "" do
      first_words <> "…"
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
end
