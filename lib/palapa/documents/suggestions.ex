defmodule Palapa.Documents.Suggestions do
  use Palapa.Context

  alias Palapa.Documents.{Page, Suggestion, SuggestionComment}
  alias Palapa.Events.Event

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
    |> preload(suggestion_comments: [author: :account])
    |> preload(closure_author: :account)
    |> Repo.all()
  end

  def get_suggestion!(queryable \\ Suggestion, id) do
    queryable
    |> Repo.get!(id)
  end

  def get_page_suggestion!(%Page{} = page, suggestion_id) do
    page
    |> Ecto.assoc(:suggestions)
    |> where([s], s.id == ^suggestion_id)
    |> where([s], is_nil(s.parent_suggestion_id))
    |> Repo.one!()
  end

  def create_suggestion(page, author, attrs) do
    author = Repo.preload(author, :account)

    suggestion_changeset =
      page
      |> Ecto.build_assoc(:suggestions)
      |> Suggestion.changeset(attrs)
      |> put_change(:organization_id, author.organization_id)
      |> put_assoc(:author, author)
      |> put_assoc(:suggestion_comments, [])

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:suggestion, suggestion_changeset)
    |> Ecto.Multi.insert(:event, fn %{suggestion: suggestion} ->
      %Event{
        action: :new_document_suggestion,
        organization_id: author.organization_id,
        author: author,
        document_id: page.document_id,
        page_id: page.id,
        document_suggestion_id: suggestion.id
      }
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{suggestion: suggestion}} ->
        {:ok, suggestion}

      {:error, _action, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def change_suggestion(suggestion \\ %Suggestion{}) do
    Suggestion.changeset(suggestion, %{})
  end

  def update_suggestion(suggestion, attrs) do
    suggestion = Repo.preload(suggestion, author: :account, attachments: [])

    Suggestion.changeset(suggestion, attrs)
    |> Repo.update()
  end

  def delete_suggestion(suggestion) do
    suggestion
    |> Repo.delete()
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

  def get_suggestion_comment!(organization, id) do
    SuggestionComment
    |> where(organization_id: ^organization.id)
    |> Repo.get!(id)
  end

  def create_suggestion_comment(suggestion, author, attrs) do
    author = Repo.preload(author, :account)
    suggestion = Repo.preload(suggestion, :page)

    suggestion_comment_changeset =
      suggestion
      |> Ecto.build_assoc(:suggestion_comments)
      |> SuggestionComment.changeset(attrs)
      |> put_change(:organization_id, author.organization_id)
      |> put_assoc(:author, author)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:suggestion_comment, suggestion_comment_changeset)
    |> Ecto.Multi.insert(:event, fn %{suggestion_comment: suggestion_comment} ->
      %Event{
        action: :new_document_suggestion_comment,
        organization_id: author.organization_id,
        author: author,
        document_id: suggestion.page.document_id,
        page_id: suggestion.page_id,
        document_suggestion_id: suggestion.id,
        document_suggestion_comment_id: suggestion_comment.id
      }
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{suggestion_comment: suggestion_comment}} ->
        {:ok, suggestion_comment}

      {:error, _action, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def change_suggestion_comment(suggestion_comment) do
    SuggestionComment.changeset(suggestion_comment, %{})
  end

  def update_suggestion_comment(suggestion_comment, attrs) do
    suggestion_comment = Repo.preload(suggestion_comment, author: :account)

    SuggestionComment.changeset(suggestion_comment, attrs)
    |> Repo.update()
  end

  def delete_suggestion_comment(suggestion_comment) do
    suggestion_comment
    |> Repo.delete()
  end
end
