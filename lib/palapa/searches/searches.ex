defmodule Palapa.Searches do
  use Palapa.Context

  import EctoEnum

  defenum(SearchResourceTypeEnum, :search_resource_type, [
    :member,
    :team,
    :message,
    :document_page
  ])

  def run(""), do: nil

  def run(search_string) do
    Repo.query!(
      """
      SELECT resource_type, title, message_id, team_id
      FROM searches
      WHERE search_index @@ plainto_tsquery('simple', $1)
      OR title ILIKE $2
      ORDER BY ts_rank(search_index, to_tsquery('simple', $3)) DESC;
      """,
      [search_string, "%#{search_string}%", search_string]
    )
  end
end
