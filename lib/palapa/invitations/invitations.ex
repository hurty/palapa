defmodule Palapa.Invitations do
  use Palapa.Context
  alias Palapa.Invitations
  alias Palapa.Organizations.Organization

  @expiration_days 30

  defdelegate(authorize(action, user, params), to: Palapa.Invitations.Policy)

  def list(%Organization{} = organization) do
    organization
    |> Ecto.assoc(:invitations)
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  def parse_emails(emails_string) do
    emails =
      emails_string
      |> String.replace(~r/\s+/, "\n")
      |> String.replace(~r/\,/, "\n")
      |> String.replace(~r/\;/, "\n")
      |> String.split("\n")
      |> Enum.reject(fn string -> string =~ ~r/^\W*$/ end)
      |> Enum.map(&String.trim(&1))
      |> Enum.uniq()

    ignored =
      emails
      |> Enum.reject(fn string -> string =~ ~r/\w+@\w+/ end)

    emails = emails -- ignored
    {:ok, emails, ignored}
  end

  def create(organization, email, creator) do
    {:ok, invitation} =
      %Invitations.Invitation{
        organization_id: organization.id,
        email: email,
        creator_id: creator.id,
        token: Palapa.Access.generate_token(),
        expire_at: Timex.shift(Timex.now(), days: @expiration_days)
      }
      |> Repo.insert(
        on_conflict: :replace_all,
        conflict_target: [:organization_id, :email]
      )

    Palapa.Emails.invitation(invitation) |> Palapa.Mailer.deliver_later()
  end
end
