defmodule Palapa.Events.Emails do
  import Bamboo.Email

  alias Palapa.Events
  alias Palapa.Accounts.Account
  alias Palapa.Organizations

  def daily_emails(%Account{} = account) do
    organizations = Organizations.list_organizations(account)

    organizations
    |> Enum.map(fn org -> email_for_organization(account, org) end)
    |> Enum.reject(&is_nil/1)
  end

  def email_for_organization(account, organization) do
    events = organization_events(account, organization)

    if Enum.any?(events) do
      events_view =
        events
        |> build_events_view(account, organization)
        |> Phoenix.HTML.html_escape()
        |> Phoenix.HTML.safe_to_string()

      email_content(account, organization, events_view)
    else
      nil
    end
  end

  def organization_events(account, organization) do
    member = Palapa.Accounts.member_for_organization(account, organization)
    Events.last_24_hours_events(organization, member)
  end

  def build_events_view(events, account, organization) do
    PalapaWeb.EventView.render("daily_recap_events.html",
      organization: organization,
      account: account,
      events: events
    )
  end

  def email_content(account, organization, events_view) do
    date =
      Timex.now()
      |> Timex.shift(hours: -24)
      |> Timex.format!("{Mfull} {D}")

    new_email()
    |> from(Application.fetch_env!(:palapa, :email_transactionnal))
    |> to(account.email)
    # References header with a unique id _tries_ to avoids clients like Gmail from grouping emails in a thread.
    |> put_header("References", ["#{Ecto.UUID.generate()}@palapa.io"])
    # Having the date in the topic also prevent grouping in thread
    |> subject("#{organization.name} daily recap for #{date}")
    |> html_body(events_view)
  end
end
