defmodule Palapa.Events do
  use Palapa.Context

  import Ecto.Query
  import EctoEnum

  alias Palapa.Events.Event
  alias Palapa.Messages
  alias Palapa.Documents
  alias Palapa.Contacts
  alias Palapa.Accounts.Account

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

  def last_50_events_without_new_messages(organization, member) do
    from(e in base_list_events_query(organization, member),
      order_by: [desc: :inserted_at],
      where: e.action != "new_message"
    )
    |> Repo.all()
  end

  def send_daily_recaps(%Account{} = account) do
    emails =
      if account.send_daily_recap do
        emails = Palapa.Events.Emails.daily_emails(account)

        Enum.each(emails, fn email -> Palapa.Mailer.deliver_now(email) end)

        emails
      else
        []
      end

    {:ok, emails}
  end

  def schedule_daily_email(account) do
    now = Timex.now(account.timezone)

    schedule_at =
      if now.hour < 7 do
        # Today at 8
        now |> Timex.set(hour: 8)
      else
        # Tomorrow at 8
        now
        |> Timex.shift(days: 1)
        |> Timex.beginning_of_day()
        |> Timex.set(hour: 8)
      end

    schedule_at_utc = Timex.Timezone.convert(schedule_at, "UTC")

    %{"type" => "daily_email", "account_id" => account.id}
    |> Palapa.JobQueue.new(schedule: schedule_at_utc)
    |> Palapa.Repo.insert()
  end

  defp base_list_events_query(organization, member) do
    from(events in subquery(all_events_query(member)),
      where: events.organization_id == ^organization.id,
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

  defp all_events_query(member) do
    from(organization_events_query(),
      union: ^members_events_query(),
      union: ^messages_events_query(member),
      union: ^documents_events_query(member),
      union: ^contact_events_query(member)
    )
  end

  defp organization_events_query() do
    from(events in Event,
      join: organizations in subquery(Organizations.Organization |> Organizations.active()),
      where: events.action == ^:new_organization
    )
  end

  defp members_events_query() do
    from events in Event,
      join: members in subquery(Organizations.Member |> Organizations.active()),
      on: events.author_id == members.id,
      where: events.action == ^:new_member
  end

  defp messages_events_query(member) do
    from(events in Event,
      join: messages in subquery(Messages.visible_to(member)),
      on: events.message_id == messages.id
    )
  end

  def documents_events_query(member) do
    from(events in Event,
      join: documents in subquery(Documents.documents_visible_to(member)),
      on: events.document_id == documents.id
    )
  end

  def contact_events_query(member) do
    from(events in Event,
      join: contacts in subquery(Contacts.visible_to(member)),
      on: events.contact_id == contacts.id
    )
  end
end
