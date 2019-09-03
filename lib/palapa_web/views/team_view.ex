defmodule PalapaWeb.TeamView do
  use PalapaWeb, :view
  use Phoenix.HTML
  alias PalapaWeb.Router
  alias PalapaWeb.Endpoint

  def team_tag(team) do
    content_tag(
      :a,
      team.name,
      href: Router.Helpers.member_path(Endpoint, :index, team.organization_id, team_id: team),
      class: "tag tag-team"
    )
  end

  def team_checked?(changeset, team) do
    teams = Ecto.Changeset.get_field(changeset, :teams)
    teams && team.id in Enum.map(teams, & &1.id)
  end
end
