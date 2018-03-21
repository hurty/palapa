defmodule PalapaWeb.TeamView do
  use PalapaWeb, :view
  use Phoenix.HTML
  alias PalapaWeb.Router

  def team_tag(conn, team) do
    content_tag(
      :a,
      team.name,
      href: Router.Helpers.member_path(conn, :index, team_id: team),
      class: "tag tag--sm mt-1 mr-1"
    )
  end
end
