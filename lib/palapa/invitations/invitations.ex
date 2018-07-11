defmodule Palapa.Invitations do
  use Palapa.Context
  alias Palapa.Invitations.Invitation
  alias Palapa.Organizations.Organization

  @expiration_days 30

  defdelegate(authorize(action, user, params), to: Palapa.Invitations.Policy)

  def list(%Organization{} = organization) do
    organization
    |> Ecto.assoc(:invitations)
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  def get(id) do
    Repo.get(Invitation, id)
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

  def create(email, creator) do
    with {:ok, invitation} <-
           %Invitation{
             organization_id: creator.organization_id,
             email: email,
             creator_id: creator.id,
             token: Palapa.Access.generate_token(),
             expire_at: Timex.shift(Timex.now(), days: @expiration_days)
           }
           |> Repo.insert(
             on_conflict: :replace_all,
             conflict_target: [:organization_id, :email]
           ),
         {:ok, _jid} <-
           Verk.enqueue(%Verk.Job{
             queue: :default,
             class: "Palapa.Invitations.Jobs.SendInvitationJob",
             args: [invitation.id]
           }) do
      {:ok, invitation}
    else
      {:error} -> "Unable to create the invitation for #{email}"
    end
  end

  def put_sent_at(invitation, at \\ Timex.now()) do
    invitation
    |> change()
    |> put_change(:email_sent_at, at)
    |> Repo.update()
  end
end
