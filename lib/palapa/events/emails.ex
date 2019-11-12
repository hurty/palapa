defmodule Palapa.Events.Emails do
  import Bamboo.Email

  alias Palapa.Events
  alias Palapa.Accounts.Account
  alias Palapa.Organizations

  def daily_emails(%Account{} = account) do
    organizations = Organizations.list_organizations(account)

    Enum.map(organizations, fn org -> email_for_organization(account, org) end)
  end

  def email_for_organization(account, organization) do
    events_view =
      organization_events(account, organization)
      |> build_events_view(account, organization)
      |> Phoenix.HTML.html_escape()
      |> Phoenix.HTML.safe_to_string()

    email_content(account, organization, events_view)
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
    new_email()
    |> from(~s[Palapa <do-not-reply@palapa.io>])
    |> to(account.email)
    |> subject("Daily recap for #{organization.name}")
    |> html_body(events_view)
  end
end
