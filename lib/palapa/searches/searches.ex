defmodule Palapa.Searches do
  use Palapa.Context

  alias Palapa.Searches.Search
  alias Palapa.Messages
  alias Palapa.Documents
  alias Palapa.Documents.Document
  alias Palapa.Contacts
  import EctoEnum

  defenum(SearchResourceTypeEnum, :search_resource_type, [
    :member,
    :team,
    :message,
    :document,
    :page,
    :contact
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
        union: ^contacts_query(member, search_string),
        union: ^teams_query(member, search_string),
        union: ^messages_query(member, search_string),
        union: ^documents_query(member, search_string),
        union: ^pages_query(member, search_string)
      )

    # cannot use bindings in `order_by` when using `union` in the above query.
    # That's because the `order_by` applies to the whole `union` and not an individual query.
    # If you really want to order the results, you can wrap the existing query in a subquery and then order it.
    search_query =
      from(q in subquery(union_query),
        order_by: [desc: q.rank, desc: q.updated_at],
        preload: [[member: :account], :contact, :team, :message, :document, [page: :document]]
      )

    search_query
    |> Repo.paginate(
      page: Keyword.get(opts, :page, 1),
      page_size: Keyword.get(opts, :page_size, 20)
    )
  end

  @blank_regex ~r/\A[[:space:]]*\z/u

  def blank_query?(param) when is_nil(param), do: true
  def blank_query?(""), do: true

  def blank_query?(string) when is_binary(string) do
    Regex.match?(@blank_regex, string)
  end

  def search_query(search_string) do
    search_string
    |> clean_search_string
    |> matching_searches_query()
  end

  def rebuild_entire_index!() do
    Repo.query!("TRUNCATE searches")
    Repo.query!("UPDATE members SET id=id")
    Repo.query!("UPDATE teams SET id=id")
    Repo.query!("UPDATE contacts SET id=id")
    Repo.query!("UPDATE messages SET id=id")
    Repo.query!("UPDATE documents SET id=id")
    Repo.query!("UPDATE pages SET id=id")
  end

  defp clean_search_string(search_string) do
    search_string
    |> String.trim()
    |> String.split()
    |> Enum.join("&")
  end

  defp matching_searches_query(queryable \\ Search, search_string) do
    from(searches in queryable,
      where: fragment("search_index @@ to_tsquery('simple', unaccent(?))", ^"#{search_string}:*")
    )
  end

  defp members_query(member, search_string) do
    from(searches in matching_searches_query(search_string),
      join: members in ^subquery(where(Member, organization_id: ^member.organization_id)),
      on: searches.member_id == members.id,
      select_merge: %{
        rank:
          fragment(
            "ts_rank(search_index, to_tsquery('simple', unaccent(?)))",
            ^"#{search_string}:*"
          )
      }
    )
  end

  defp teams_query(member, search_string) do
    from(searches in matching_searches_query(search_string),
      join: teams in ^subquery(Teams.where_organization(member.organization_id)),
      on: searches.team_id == teams.id,
      select_merge: %{
        rank:
          fragment(
            "ts_rank(search_index, to_tsquery('simple', unaccent(?)))",
            ^"#{search_string}:*"
          )
      }
    )
  end

  defp contacts_query(member, search_string) do
    from(searches in matching_searches_query(search_string),
      join: contacts in ^subquery(Contacts.visible_to(member)),
      on: searches.contact_id == contacts.id,
      select_merge: %{
        rank:
          fragment(
            "ts_rank(search_index, to_tsquery('simple', unaccent(?)))",
            ^"#{search_string}:*"
          )
      }
    )
  end

  defp messages_query(member, search_string) do
    from(searches in matching_searches_query(search_string),
      join: messages in ^subquery(Messages.visible_to(member)),
      on: searches.message_id == messages.id,
      where: is_nil(messages.deleted_at),
      select_merge: %{
        rank:
          fragment(
            "ts_rank(search_index, to_tsquery('simple', unaccent(?)))",
            ^"#{search_string}:*"
          )
      }
    )
  end

  defp documents_query(member, search_string) do
    from(searches in matching_searches_query(search_string),
      join: documents in ^subquery(Documents.documents_visible_to(member)),
      on: searches.document_id == documents.id,
      where: is_nil(documents.deleted_at),
      select_merge: %{
        rank:
          fragment(
            "ts_rank(search_index, to_tsquery('simple', unaccent(?)))",
            ^"#{search_string}:*"
          )
      }
    )
  end

  defp pages_query(member, search_string) do
    from(searches in matching_searches_query(search_string),
      join: pages in ^subquery(Documents.pages_visible_to(member)),
      on: searches.page_id == pages.id,
      join: documents in Document,
      on: pages.document_id == documents.id,
      where: is_nil(pages.deleted_at),
      where: is_nil(documents.deleted_at),
      select_merge: %{
        rank:
          fragment(
            "ts_rank(search_index, to_tsquery('simple', unaccent(?)))",
            ^"#{search_string}:*"
          )
      }
    )
  end
end
