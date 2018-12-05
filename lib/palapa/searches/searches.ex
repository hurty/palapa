defmodule Palapa.Searches do
  use Palapa.Context

  alias Palapa.Searches.{SearchResult}
  alias Palapa.Messages

  import EctoEnum

  defenum(SearchResourceTypeEnum, :search_resource_type, [
    :member,
    :team,
    :message,
    :page
  ])

  def search(""), do: nil

  def search(%Member{} = member, search_string) do
    search_string = clean_search_string(search_string)

    member = Repo.preload(member, :organization)

    results =
      from(
        searches in "searches",
        where:
          fragment("search_index @@ to_tsquery('simple', unaccent(?))", ^"#{search_string}:*"),
        order_by:
          fragment(
            "ts_rank(search_index, to_tsquery('simple', unaccent(?))) DESC",
            ^"#{search_string}:*"
          ),
        left_join: teams in ^subquery(Teams.where_organization(member.organization_id)),
        on: searches.team_id == teams.id,
        left_join: members in ^subquery(Ecto.assoc(member.organization, :members)),
        on: searches.member_id == members.id,
        left_join: accounts in Palapa.Accounts.Account,
        on: members.account_id == accounts.id,
        left_join: messages in ^subquery(Messages.visible_to(member)),
        on: searches.message_id == messages.id,
        # /!\ to be restrained to visible pages only
        left_join: pages in Palapa.Documents.Page,
        on: searches.page_id == pages.id,
        select: %{
          resource_type: searches.resource_type,
          resource_id:
            coalesce(searches.message_id, searches.team_id)
            |> coalesce(searches.member_id)
            |> coalesce(searches.page_id),
          title:
            coalesce(messages.title, teams.name)
            |> coalesce(accounts.name)
            |> coalesce(pages.title),
          updated_at: searches.updated_at
        },
        distinct: [searches.member_id, searches.team_id, searches.message_id, searches.page_id]
      )
      |> Repo.all()

    Enum.map(results, fn result -> Repo.load(SearchResult, result) end)
  end

  def clean_search_string(search_string) do
    search_string
    |> String.split()
    |> Enum.join("&")
  end
end
