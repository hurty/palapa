defmodule Palapa.Events.Event do
  use Palapa.Schema

  alias Palapa.Events.EventAction

  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Messages.{Message, MessageComment}

  alias Palapa.Documents.{Document, Page, Suggestion, SuggestionComment}

  schema "events" do
    field(:action, EventAction)
    timestamps(updated_at: false)
    belongs_to(:organization, Organization)
    belongs_to(:author, Member)

    # Event targets
    belongs_to(:message, Message)
    belongs_to(:message_comment, MessageComment)
    belongs_to(:document, Document)
    belongs_to(:page, Page)
    belongs_to(:document_suggestion, Suggestion)
    belongs_to(:document_suggestion_comment, SuggestionComment)
  end
end
