defmodule PalapaWeb.AnnouncementView do
  use PalapaWeb, :view

  def excerpt(content) do
    first_words =
      content
      |> String.slice(0..380)
      |> strip_html_tags()

    if first_words != "" do
      first_words <> "..."
    end
  end

  def strip_html_tags(content) when is_nil(content), do: ""

  def strip_html_tags(content) do
    content
    |> String.replace(~r/<.*?>/, "")
    |> String.replace("&nbsp;", "")
  end

  def announcement_teams_tags(conn, announcement) do
    teams =
      announcement
      |> Palapa.Repo.preload(:teams)
      |> Map.get(:teams)

    if Enum.any?(teams) do
      content_tag :div, class: "flex flex-wrap" do
        Enum.map(teams, fn team ->
          PalapaWeb.TeamView.team_tag(conn, team)
        end)
      end
    end
  end
end
