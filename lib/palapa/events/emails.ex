defmodule Palapa.Events.Emails do
  import Bamboo.Email
  import Palapa.Gettext
  alias Palapa.Events
  alias Palapa.Accounts.Account
  alias Palapa.Organizations

  def daily_emails(%Account{} = account) do
    locale = account.locale || "en"

    Gettext.with_locale(Palapa.Gettext, locale, fn ->
      organizations = Organizations.list_organizations(account)

      organizations
      |> Enum.map(fn org -> email_for_organization(account, org) end)
      |> Enum.reject(&is_nil/1)
    end)
  end

  def email_for_organization(account, organization) do
    locale = Gettext.get_locale(Palapa.Gettext)

    date_format =
      case locale do
        "en" -> "{Mfull} {D}"
        _ -> "{D} {Mfull}"
      end

    formatted_date =
      Timex.now(account.timezone || "UTC")
      |> Timex.shift(hours: -24)
      |> Timex.lformat!(date_format, locale)

    events = organization_events(account, organization)

    if Enum.any?(events) do
      events_view =
        events
        |> build_events_view(account, organization, formatted_date)
        |> Phoenix.HTML.html_escape()
        |> Phoenix.HTML.safe_to_string()

      email_content(account, organization, formatted_date, events_view)
    else
      nil
    end
  end

  def organization_events(account, organization) do
    member = Palapa.Accounts.member_for_organization(account, organization)
    Events.last_24_hours_events(organization, member)
  end

  def build_events_view(events, account, organization, formatted_date) do
    PalapaWeb.EventView.render("daily_recap_events.html",
      organization: organization,
      account: account,
      events: events,
      formatted_date: formatted_date
    )
  end

  def email_content(account, organization, formatted_date, events_view) do
    new_email()
    |> from(Application.fetch_env!(:palapa, :email_transactionnal))
    |> to(account.email)
    # References header with a unique id _tries_ to avoids clients like Gmail from grouping emails in a thread.
    |> put_header("References", ["#{Ecto.UUID.generate()}@palapa.io"])
    # Having the date in the topic also prevent grouping in thread
    |> subject(
      gettext("%{organization} daily recap for %{date}", %{
        organization: organization.name,
        date: formatted_date
      })
    )
    |> html_body(events_view)
  end
end
