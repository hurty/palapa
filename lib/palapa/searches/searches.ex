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

  @empty_page_result %Scrivener.Page{
    entries: [],
    page_number: 1,
    page_size: 1,
    total_entries: 0,
    total_pages: 1
  }

  def search(member, search_string, opts \\ [])
  def search(%Member{}, nil, _opts), do: @empty_page_result
  def search(%Member{}, "", _opts), do: @empty_page_result

  def search(%Member{} = member, search_string, opts) do
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
        }
      )
      |> Repo.paginate(
        page: Keyword.get(opts, :page, 1),
        page_size: Keyword.get(opts, :page_size, 20)
      )

    cast_entries = Enum.map(results, fn result -> Repo.load(SearchResult, result) end)

    Map.put(results, :entries, cast_entries)
  end

  def rebuild_entire_index!() do
    Repo.query!("TRUNCATE searches")
    Repo.query!("UPDATE members SET id=id")
    Repo.query!("UPDATE teams SET id=id")
    Repo.query!("UPDATE messages SET id=id")
    Repo.query!("UPDATE pages SET id=id")
  end

  defp clean_search_string(search_string) do
    search_string
    |> String.trim()
    |> String.split()
    |> Enum.join("&")
  end
end
