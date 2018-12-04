defmodule Palapa.Searches do
  use Palapa.Context

  import EctoEnum

  defenum(SearchResourceTypeEnum, :search_resource_type, [
    :member,
    :team,
    :message,
    :page
  ])

  def run(""), do: nil

  def run(search_string) do
    Repo.query!(
      """
      SELECT resource_type, message_id, team_id
      FROM searches
      WHERE search_index @@ plainto_tsquery('simple', $1)
      ORDER BY ts_rank(search_index, plainto_tsquery('simple', $2)) DESC;
      """,
      [search_string, search_string]
    )
  end
end
