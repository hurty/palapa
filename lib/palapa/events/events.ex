defmodule Palapa.Events do
  use Palapa.Context

  import Ecto.Query
  import EctoEnum

  alias Palapa.Messages
  alias Palapa.Documents
  alias Palapa.Contacts

  defenum(EventActionEnum, :event_action, ~w(
    new_organization
    delete_organization
    new_member
    new_message
    new_message_comment
    new_document
    new_document_page
    new_document_suggestion
    new_document_suggestion_comment
    close_document_suggestion
    new_contact
    new_contact_comment
  )s)

  def last_24_hours_events(organization, member) do
    time = Timex.now() |> Timex.shift(hours: -24)

    from(e in base_list_events_query(organization, member),
      where: e.inserted_at > ^time,
      order_by: [asc: :inserted_at]
    )
    |> Repo.all()
  end

  def last_50_events(organization, member) do
    from(e in base_list_events_query(organization, member),
      order_by: [desc: :inserted_at]
    )
    |> Repo.all()
  end

  defp base_list_events_query(organization, member) do
    from(events in subquery(all_events_query(organization, member)),
      limit: 50,
      distinct: true,
      preload: [author: :account],
      preload: [
        :organization,
        :message,
        :message_comment,
        :document,
        :page,
        :document_suggestion_comment,
        :contact,
        :contact_comment
      ],
      preload: [document_suggestion: [author: :account]]
    )
  end

  def all_events_query(organization, member) do
    from(messages_events_query(organization, member),
      union: ^documents_events_query(organization, member),
      union: ^organization_events_query(organization),
      union: ^contact_events_query(organization, member)
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

  def contact_events_query(organization, member) do
    from(events in Ecto.assoc(organization, :events),
      join: contacts in subquery(Contacts.visible_to(member)),
      on: events.contact_id == contacts.id
    )
  end
end
