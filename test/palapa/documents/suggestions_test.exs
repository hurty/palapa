defmodule Palapa.DocumentsTest do
  use Palapa.DataCase

  alias Palapa.Documents
  alias Palapa.Documents.Suggestions
  alias Palapa.Documents.{Suggestion, SuggestionComment}
  alias Palapa.Events.Event

  import Palapa.Factory

  @document_attrs %{title: "some title"}

  describe "suggestion" do
    setup do
      organization = insert!(:organization)
      author = insert!(:member, organization: organization)
      {:ok, document} = Documents.create_document(author, nil, @document_attrs)
      first_page = Documents.get_first_page(document)

      %{document: document, page: first_page, author: author}
    end

    test "create a new suggestion", %{document: document, page: page, author: author} do
      assert {:ok, %Suggestion{} = suggestion} =
               Suggestions.create_suggestion(page, author, %{content: "some suggestion"})

      event_query =
        from(events in Event,
          where:
            events.document_id == ^document.id and events.document_suggestion_id == ^suggestion.id
        )

      assert Repo.exists?(event_query)
    end
  end

  describe "suggestion comment" do
    setup do
      organization = insert!(:organization)
      author = insert!(:member, organization: organization)
      {:ok, document} = Documents.create_document(author, nil, @document_attrs)
      first_page = Documents.get_first_page(document)

      {:ok, suggestion} =
        Suggestions.create_suggestion(first_page, author, %{content: "some suggestion"})

      %{
        document: document,
        suggestion: suggestion,
        author: author
      }
    end

    test "create a new suggestion comment", %{
      document: document,
      suggestion: suggestion,
      author: author
    } do
      assert {:ok, %SuggestionComment{} = suggestion_comment} =
               Suggestions.create_suggestion_comment(suggestion, author, %{
                 content: "yes it's a good suggestion"
               })

      event_query =
        from(events in Event,
          where:
            events.document_id == ^document.id and
              events.document_suggestion_comment_id == ^suggestion_comment.id
        )

      assert Repo.exists?(event_query)
    end
  end
end
