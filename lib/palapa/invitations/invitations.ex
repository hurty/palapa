defmodule Palapa.Invitations do
  use Palapa.Context
  alias Palapa.Invitations.Invitation
  alias Palapa.Invitations.JoinForm
  alias Palapa.Organizations
  alias Palapa.Organizations.Organization
  alias Palapa.Accounts

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
    |> preload(:organization)
    |> Repo.get(id)
  end

  def get!(queryable \\ Invitation, id) do
    queryable
    |> preload(:organization)
    |> Repo.get!(id)
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

  def create(email, %Member{} = creator) do
    new_invitation = %Invitation{
      organization_id: creator.organization_id,
      email: email,
      creator_id: creator.id,
      token: Palapa.Access.generate_token(),
      expire_at: Timex.shift(Timex.now(), days: @expiration_days),
      email_sent_at: nil
    }

    with {:ok, invitation} <-
           Repo.insert(
             new_invitation,
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

  def mark_as_sent(%Invitation{} = invitation, at \\ Timex.now()) do
    invitation
    |> change()
    |> put_change(:email_sent_at, at)
    |> Repo.update()
  end

  def authorized?(%Invitation{} = invitation, token) when is_binary(token) do
    invitation.token == token && Timex.after?(invitation.expire_at, Timex.now())
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
        {:already_account, account, member}

      true ->
        {:none, account, member}
    end
  end

  def join(%Invitation{} = invitation, attrs) do
    {status, account, member} = retrieve_account_from_invitation(invitation)

    case status do
      :already_member ->
        {:ok, %{account: account, member: member}}

      :already_account ->
        join_with_existing_account(invitation, account, attrs)

      _ ->
        join_and_create_new_account(invitation, attrs)
    end
  end

  defp join_and_create_new_account(invitation, attrs) do
    member_attrs = Map.take(attrs, ["name", "title"])

    account_attrs =
      Map.take(attrs, ["password", "timezone"])
      |> Map.put("email", invitation.email)

    changeset = JoinForm.changeset(%JoinForm{}, attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:validation, fn _ ->
      JoinForm.validate(changeset)
    end)
    |> Ecto.Multi.run(:account, fn _changes ->
      Accounts.create(account_attrs)
    end)
    |> Ecto.Multi.run(:member, fn changes ->
      Organizations.create_member(%{
        organization_id: invitation.organization_id,
        account_id: changes.account.id,
        name: member_attrs["name"],
        title: member_attrs["title"],
        role: :member
      })
    end)
    |> Ecto.Multi.run(:delete_invitation, fn _changes ->
      delete(invitation)
    end)
    |> Repo.transaction()
  end

  defp join_with_existing_account(invitation, account, attrs) do
    member_attrs = Map.take(attrs, ["name", "title"])
    changeset = JoinForm.changeset(%JoinForm{}, attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:validation, fn _ ->
      JoinForm.validate(changeset)
    end)
    |> Ecto.Multi.run(:account, fn _ -> {:ok, account} end)
    |> Ecto.Multi.run(:member, fn _changes ->
      Organizations.create_member(%{
        organization_id: invitation.organization_id,
        account_id: account.id,
        name: member_attrs["name"],
        title: member_attrs["title"],
        role: :member
      })
    end)
    |> Ecto.Multi.run(:delete_invitation, fn _changes ->
      delete(invitation)
    end)
    |> Repo.transaction()
  end
end
