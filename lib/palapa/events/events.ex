defmodule Palapa.Events do
  use Palapa.Context

  import Ecto.Query
  import EctoEnum

  alias Palapa.Events.Event, warn: false
  alias Palapa.Messages

  defenum(EventAction, :event_action, ~w(
    new_message
    new_message_comment
    new_document
    new_document_page
    new_document_suggestion
    new_document_suggestion_comment
    new_member
  )s)

  def list_events(organization, member) do
    from(events in Ecto.assoc(organization, :events),
      order_by: [desc: :inserted_at],
      limit: 30,
      left_join: messages in Messages.Message,
      on: events.message_id == messages.id,
      as: :messages,
      preload: [message: messages],
      preload: [author: :account],
      join: m in subquery(Messages.visible_to(member)),
      distinct: true
    )
    |> Repo.all()
  end
end
