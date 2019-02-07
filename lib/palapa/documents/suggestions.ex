defmodule Palapa.Documents.Suggestions do
  use Palapa.Context

  alias Palapa.Documents.{Page, Suggestion}

  # --- Scopes

  def suggestions_visible_to(queryable \\ Suggestion, %Member{} = member) do
    from(suggestions in queryable,
      join: documents in assoc(suggestions, :document),
      where: documents.organization_id == ^member.organization_id and is_nil(documents.team_id),
      or_where: documents.team_id in ^Teams.list_ids_for_member(member)
    )
  end

  def open_suggestions(queryable \\ Suggestion) do
    queryable
    |> where([q], is_nil(q.closed_at))
  end

  def closed_suggestions(queryable \\ Suggestion) do
    queryable
    |> where([q], not is_nil(q.closed_at))
  end

  # --- Actions

  def list_suggestions(queryable \\ Suggestion, page) do
    queryable
    |> where([s], s.page_id == ^page.id and is_nil(s.parent_suggestion_id))
    |> order_by(:inserted_at)
    |> preload(author: :account)
    |> preload(replies: [author: :account])
    |> Repo.all()
  end

  def get_suggestion!(queryable \\ Suggestion, id) do
    queryable
    |> Repo.get!(id)
  end

  def get_suggestion!(%Page{} = page, suggestion_id, top_level: true) do
    page
    |> Ecto.assoc(:suggestions)
    |> where([s], s.id == ^suggestion_id)
    |> where([s], is_nil(s.parent_suggestion_id))
    |> Repo.one!()
  end

  def get_suggestion!(%Page{} = page, suggestion_id, top_level: false) do
    page
    |> Ecto.assoc(:suggestions)
    |> where([s], s.id == ^suggestion_id)
    |> where([s], not is_nil(s.parent_suggestion_id))
    |> Repo.one()
  end

  def create_suggestion(page, author, parent_suggestion, attrs) do
    author = Repo.preload(author, :account)

    page
    |> Ecto.build_assoc(:suggestions)
    |> Suggestion.changeset(attrs)
    |> put_assoc(:author, author)
    |> put_assoc(:parent_suggestion, parent_suggestion)
    |> put_assoc(:replies, [])
    |> Repo.insert()
  end

  def change_suggestion(suggestion \\ %Suggestion{}) do
    Suggestion.changeset(suggestion, %{})
  end

  def close_suggestion(suggestion, author) do
    suggestion
    |> change(%{
      closed_at: DateTime.utc_now() |> DateTime.truncate(:second),
      closure_author_id: author.id
    })
    |> Repo.update()
  end

  def reopen_suggestion(suggestion) do
    suggestion
    |> change(%{
      closed_at: nil,
      closure_author_id: nil
    })
    |> Repo.update()
  end
end
