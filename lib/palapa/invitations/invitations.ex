defmodule Palapa.Invitations do
  use Palapa.Context
  alias Palapa.Invitations.Invitation
  alias Palapa.Organizations.Organization

  @expiration_days 30

  defdelegate(authorize(action, user, params), to: Palapa.Invitations.Policy)

  # --- Scopes
  def visible_to(queryable \\ Invitation, %Member{} = member) do
    queryable
    |> where(organization_id: ^member.organization_id)
  end

  # --- Actions

  def list(%Organization{} = organization) do
    organization
    |> Ecto.assoc(:invitations)
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  def get(queryable \\ Invitation, id) do
    queryable
    |> Repo.get(id)
  end

  def get!(queryable \\ Invitation, id) do
    queryable
    |> Repo.get!(id)
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

  def create(email, %Member{} = creator) do
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

  def delete(%Invitation{} = invitation) do
    invitation
    |> Repo.delete()
  end

  def renew(%Invitation{} = invitation, creator) do
    with {:ok, _} <- delete(invitation),
         {:ok, new_invitation} <- create(invitation.email, creator) do
      {:ok, new_invitation}
    else
      {:error} -> {:error, "Unable to renew the invitation for #{invitation.email}"}
    end
  end

  def update_sent_at(invitation, at \\ Timex.now()) do
    invitation
    |> change()
    |> put_change(:email_sent_at, at)
    |> Repo.update()
  end
end
