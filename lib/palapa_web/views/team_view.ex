defmodule PalapaWeb.TeamView do
  use PalapaWeb, :view
  use Phoenix.HTML
  alias PalapaWeb.Router

  def team_tag(conn, team) do
    content_tag(
      :a,
      team.name,
      href:
        Router.Helpers.member_path(conn, :index, conn.assigns.current_organization, team_id: team),
      class: "tag"
    )
  end

  def team_checked?(changeset, team) do
    teams = Ecto.Changeset.get_field(changeset, :teams)
    teams && team.id in Enum.map(teams, & &1.id)
  end
end
