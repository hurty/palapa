defmodule Palapa.Invitations do
  use Palapa.Context
  alias Palapa.Invitations
  alias Palapa.Invitations.Invitation
  alias Palapa.Invitations.JoinForm
  alias Palapa.Organizations
  alias Palapa.Organizations.Organization
  alias Palapa.Accounts
  alias Palapa.Events
  alias Palapa.Events.Event

  @expiration_days 30

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
    |> preload(:organization)
    |> Repo.get(id)
  end

  def get!(queryable \\ Invitation, id) do
    queryable
    |> preload(:organization)
    |> Repo.get!(id)
  end

  def get_by_organization_id_and_email(organization_id, email) do
    Invitation
    |> preload(:organization)
    |> where(organization_id: ^organization_id, email: ^email)
    |> Repo.one()
  end

  # Parse emails, reject malformed ones and people who are already members of the given organization
  def parse_emails(emails_string, %Organization{} = organization) do
    {:ok, emails, malformed} = parse_emails(emails_string)

    already_members_emails =
      Palapa.Organizations.list_members(organization)
      |> Enum.map(fn member -> member.account.email end)

    already_members = Enum.filter(emails, fn string -> string in already_members_emails end)

    emails = emails -- already_members
    {:ok, emails, malformed, already_members}
  end

  # Parse emails and reject malformed ones
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

    malformed = Enum.reject(emails, fn string -> string =~ ~r/\w+@\w+/ end)
    emails = emails -- malformed
    {:ok, emails, malformed}
  end

  def create_or_renew(email, %Member{} = creator) do
    existing_invitation = get_by_organization_id_and_email(creator.organization_id, email)

    new_invitation = %Invitation{
      organization_id: creator.organization_id,
      email: email,
      creator_id: creator.id,
      token: Palapa.Access.generate_token(),
      expire_at:
        Timex.shift(DateTime.utc_now(), days: @expiration_days) |> DateTime.truncate(:second),
      email_sent_at: nil
    }

    Ecto.Multi.new()
    |> Ecto.Multi.run(:delete_existing_invitation, fn _repo, _changes ->
      if existing_invitation do
        delete(existing_invitation)
      else
        {:ok, nil}
      end
    end)
    |> Ecto.Multi.run(:invitation, fn _repo, _changes ->
      Repo.insert(new_invitation)
    end)
    |> Ecto.Multi.run(:send_invitation, fn _repo, changes ->
      send_invitation(changes.invitation)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, result.invitation}

      _ ->
        {:error, "Unable to create the invitation for #{email}"}
    end
  end

  def delete(%Invitation{} = invitation) do
    invitation
    |> Repo.delete()
  end

  def send_invitation(%Invitation{} = invitation) do
    if invitation_sent?(invitation) do
      {:ignore, "invitation already sent"}
    else
      Invitations.Emails.invitation(invitation)
      |> Palapa.Mailer.deliver_later()

      Invitations.mark_as_sent(invitation)
    end
  end

  def invitation_sent?(invitation) do
    invitation.email_sent_at
  end

  def mark_as_sent(%Invitation{} = invitation, at \\ DateTime.utc_now()) do
    invitation
    |> change()
    |> put_change(:email_sent_at, DateTime.truncate(at, :second))
    |> Repo.update()
  end

  def authorized?(%Invitation{} = invitation, token) when is_binary(token) do
    invitation.token == token && Timex.after?(invitation.expire_at, DateTime.utc_now())
  end

  def retrieve_account_from_invitation(invitation) do
    account = Accounts.get_by(email: invitation.email)

    member =
      if account do
        Organizations.get_member_from_account(invitation.organization, account)
      else
        nil
      end

    cond do
      account && member ->
        delete(invitation) && {:already_member, account, member}

      account && !member ->
        {:existing_account, account, member}

      true ->
        {:none, account, member}
    end
  end

  def join(%Invitation{} = invitation, attrs) do
    {status, account, member} = retrieve_account_from_invitation(invitation)

    case status do
      :already_member ->
        {:ok, %{account: account, member: member}}

      :existing_account ->
        join_with_existing_account(invitation, account, attrs)

      _ ->
        join_and_create_new_account(invitation, attrs)
    end
  end

  defp join_and_create_new_account(invitation, attrs) do
    member_attrs = Map.take(attrs, ["title"])

    account_attrs =
      Map.take(attrs, ["name", "avatar", "password", "timezone"])
      |> Map.put("email", invitation.email)

    changeset = JoinForm.changeset(%JoinForm{}, attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:validation, fn _repo, _changes ->
      JoinForm.validate(changeset)
    end)
    |> Ecto.Multi.run(:account, fn _repo, _changes ->
      Accounts.create(account_attrs)
    end)
    |> Ecto.Multi.run(:member, fn _repo, changes ->
      Organizations.create_member(%{
        organization_id: invitation.organization_id,
        account_id: changes.account.id,
        title: member_attrs["title"],
        role: :member
      })
    end)
    |> Ecto.Multi.run(:daily_email, fn _, %{account: account} ->
      Events.schedule_daily_email(account)
    end)
    |> Ecto.Multi.insert(:event, fn %{member: member} ->
      %Event{
        action: :new_member,
        organization_id: member.organization_id,
        author: member
      }
    end)
    |> Ecto.Multi.run(:delete_invitation, fn _repo, _changes ->
      delete(invitation)
    end)
    |> Repo.transaction()
  end

  defp join_with_existing_account(invitation, account, attrs) do
    changeset = JoinForm.changeset_for_existing_account(%JoinForm{}, attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:validation, fn _repo, _changes ->
      JoinForm.validate(changeset)
    end)
    |> Ecto.Multi.run(:account, fn _repo, _changes -> {:ok, account} end)
    |> Ecto.Multi.run(:member, fn _repo, _changes ->
      Organizations.create_member(%{
        organization_id: invitation.organization_id,
        account_id: account.id,
        title: attrs["title"],
        role: :member
      })
    end)
    |> Ecto.Multi.insert(:event, fn %{member: member} ->
      %Event{
        action: :new_member,
        organization_id: member.organization_id,
        author: member
      }
    end)
    |> Ecto.Multi.run(:delete_invitation, fn _repo, _changes ->
      delete(invitation)
    end)
    |> Repo.transaction()
  end
end
