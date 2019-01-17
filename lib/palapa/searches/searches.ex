defmodule Palapa.Searches do
  use Palapa.Context

  alias Palapa.Messages
  alias Palapa.Documents
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
    member = Repo.preload(member, :organization)
    search_string = clean_search_string(search_string)

    union_query =
      from(
        searches in members_query(member, search_string),
        union: ^teams_query(member, search_string),
        union: ^messages_query(member, search_string),
        union: ^pages_query(member, search_string)
      )

    # cannot use bindings in `order_by` when using `union` in the above query.
    # That's because the `order_by` applies to the whole `union` and not an individual query.
    # If you really want to order the results, you can wrap the existing query in a subquery and then order it.
    search_query = from(q in subquery(union_query), order_by: [desc: q.rank, desc: q.updated_at])

    search_query
    |> Repo.paginate(
      page: Keyword.get(opts, :page, 1),
      page_size: Keyword.get(opts, :page_size, 20)
    )
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

  defp matching_searches_query(search_string) do
    from(searches in "searches",
      where: fragment("search_index @@ to_tsquery('simple', unaccent(?))", ^"#{search_string}:*")
    )
  end

  def members_query(member, search_string) do
    from(searches in matching_searches_query(search_string),
      join: members in ^subquery(where(Member, organization_id: ^member.organization_id)),
      on: searches.member_id == members.id,
      join: accounts in Palapa.Accounts.Account,
      on: members.account_id == accounts.id,
      select: %{
        resource_type: searches.resource_type,
        resource_id: members.id,
        title: accounts.name,
        updated_at: searches.updated_at,
        rank:
          fragment(
            "ts_rank(search_index, to_tsquery('simple', unaccent(?)))",
            ^"#{search_string}:*"
          )
      }
    )
  end

  def teams_query(member, search_string) do
    from(searches in matching_searches_query(search_string),
      join: teams in ^subquery(Teams.where_organization(member.organization_id)),
      on: searches.team_id == teams.id,
      select: %{
        resource_type: searches.resource_type,
        resource_id: searches.team_id,
        title: teams.name,
        updated_at: searches.updated_at,
        rank:
          fragment(
            "ts_rank(search_index, to_tsquery('simple', unaccent(?)))",
            ^"#{search_string}:*"
          )
      }
    )
  end

  def messages_query(member, search_string) do
    from(searches in matching_searches_query(search_string),
      join: messages in ^subquery(Messages.visible_to(member)),
      on: searches.message_id == messages.id,
      select: %{
        resource_type: searches.resource_type,
        resource_id: searches.message_id,
        title: messages.title,
        updated_at: searches.updated_at,
        rank:
          fragment(
            "ts_rank(search_index, to_tsquery('simple', unaccent(?)))",
            ^"#{search_string}:*"
          )
      }
    )
  end

  def pages_query(member, search_string) do
    from(searches in matching_searches_query(search_string),
      join: pages in ^subquery(Documents.pages_visible_to(member)),
      on: searches.page_id == pages.id,
      select: %{
        resource_type: searches.resource_type,
        resource_id: searches.page_id,
        title: pages.title,
        updated_at: searches.updated_at,
        rank:
          fragment(
            "ts_rank(search_index, to_tsquery('simple', unaccent(?)))",
            ^"#{search_string}:*"
          )
      }
    )
  end
end
