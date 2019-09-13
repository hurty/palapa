defmodule Palapa.Events do
  use Palapa.Context

  import Ecto.Query
  import EctoEnum

  alias Palapa.Messages
  alias Palapa.Documents

  defenum(EventAction, :event_action, ~w(
    new_organization
    new_member
    new_message
    new_message_comment
    new_document
    new_document_page
    new_document_suggestion
    new_document_suggestion_comment
    close_document_suggestion
    new_contact
  )s)

  def list_events(member) do
    from(events in subquery(all_events_query(member)),
      limit: 30,
      order_by: [desc: :inserted_at],
      distinct: true,
      preload: [author: :account],
      preload: [
        :organization,
        :message,
        :message_comment,
        :document,
        :page,
        :document_suggestion_comment
      ],
      preload: [document_suggestion: [author: :account]]
    )
    |> Repo.all()
  end

  def all_events_query(member) do
    member = Repo.preload(member, :organization)

    from(messages_events_query(member.organization, member),
      union: ^documents_events_query(member.organization, member),
      union: ^organization_events_query(member.organization)
    )
  end

  def organization_events_query(organization) do
    from(events in Ecto.assoc(organization, :events),
      where: events.action == ^:new_organization,
      or_where: events.action == ^:new_member
    )
  end

  def messages_events_query(organization, member) do
    from(events in Ecto.assoc(organization, :events),
      join: messages in subquery(Messages.visible_to(member)),
      on: events.message_id == messages.id
    )
  end

  def documents_events_query(organization, member) do
    from(events in Ecto.assoc(organization, :events),
      join: documents in subquery(Documents.documents_visible_to(member)),
      on: events.document_id == documents.id
    )
  end
end
