defmodule Palapa.Organizations do
  use Palapa.Context
  use Palapa.SoftDelete

  alias Organizations.{Organization, Member, PersonalInformation}
  alias Palapa.Accounts.Account
  alias Palapa.Events.Event

  import EctoEnum
  defenum(RoleEnum, :role, [:owner, :admin, :member])

  ### Scopes

  def with_member_name(queryable \\ Member, name_pattern) do
    if name_pattern do
      escaped_pattern = Repo.escape_like_pattern(name_pattern) <> "%"
      where(queryable, [q], ilike(q.name, ^escaped_pattern))
    else
      queryable
    end
  end

  ### Actions

  def list_organizations(%Account{} = account) do
    Ecto.assoc(account, [:active_members, :organization])
    |> active()
    |> order_by([o], o.name)
    |> Repo.all()
  end

  def get(id) do
    Repo.get(Organization, id)
  end

  def get!(id) do
    Repo.get!(Organization, id)
  end

  def create(organization_attrs, creator_account, locale \\ "en", existing_customer \\ nil) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:organization, fn repo, _changes ->
      %Organization{}
      |> Organization.changeset(organization_attrs)
      |> put_assoc(:creator_account, creator_account)
      |> repo.insert()
    end)
    |> Ecto.Multi.run(:member, fn _repo, changes ->
      Organizations.create_member(%{
        organization_id: changes.organization.id,
        account_id: creator_account.id,
        role: :owner
      })
    end)
    |> Ecto.Multi.insert(:event, fn %{organization: organization, member: member} ->
      %Event{
        action: :new_organization,
        organization: organization,
        author: member
      }
    end)
    |> Ecto.Multi.run(:welcome_message, fn _repo, %{organization: organization} ->
      Palapa.PublicSeeds.seed(organization, locale)
    end)
    |> Ecto.Multi.run(:subscription, fn _repo, %{organization: organization} ->
      if existing_customer do
        case Palapa.Billing.Subscriptions.create_subscription(organization, existing_customer) do
          {:ok, subscription} -> {:ok, subscription}
          {:error, :stripe_subscription, error, _} -> {:error, error}
          {:error, :subscription, changeset, _} -> {:error, changeset}
        end
      else
        {:ok, nil}
      end
    end)
    |> Repo.transaction()
  end

  def update(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  def change(organization) do
    Organization.changeset(organization, %{})
  end

  def list_admins(organization) do
    organization
    |> Ecto.assoc(:members)
    |> where([m], m.role == "admin")
    |> join(:inner, [m], a in assoc(m, :account))
    |> order_by([_, a], a.name)
    |> Repo.all()
  end

  def list_owners(organization) do
    organization
    |> Ecto.assoc(:members)
    |> where([m], m.role == "owner")
    |> join(:inner, [m], a in assoc(m, :account))
    |> order_by([_, a], a.name)
    |> Repo.all()
  end

  def delete(%Organization{} = organization, author \\ nil) do
    Multi.new()
    |> Multi.run(:organization, fn _, _ -> soft_delete(organization) end)
    |> Multi.run(:event, fn repo, %{organization: org} ->
      if author do
        %Event{
          action: :delete_organization,
          organization: org,
          author: author
        }
        |> repo.insert()
      else
        {:ok, nil}
      end
    end)
    |> Oban.insert(
      :cancel_subscription,
      Palapa.Billing.Workers.CancelSubscription.new(%{organization_id: organization.id})
    )
    |> Repo.transaction()
  end

  def active_organizations_having_owner(%Account{} = account) do
    from(organizations in Ecto.assoc(account, :organizations),
      where: is_nil(organizations.deleted_at),
      join: members in assoc(organizations, :members),
      where: members.role == "owner" and members.account_id == ^account.id
    )
  end

  defp organizations_ids_with_only_one_owner() do
    from(members in Member,
      where: members.role == "owner",
      group_by: members.organization_id,
      having: count(members.role) == 1,
      select: members.organization_id
    )
    |> Repo.all()
  end

  def organizations_to_delete_when_deleting_account(%Account{} = account) do
    from(
      organizations in active_organizations_having_owner(account),
      where: organizations.id in ^organizations_ids_with_only_one_owner()
    )
  end

  def delete_organizations_with_only_owner(%Account{} = account) do
    organizations = organizations_to_delete_when_deleting_account(account) |> Repo.all()

    Enum.each(organizations, fn org ->
      Organizations.Workers.DeleteOrganization.new(%{organization_id: org.id})
      |> Oban.insert()
    end)

    {:ok, organizations}
  end

  def delete_all_account_memberships(%Account{} = account) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    from(members in Member,
      where: members.account_id == ^account.id
    )
    |> Repo.update_all(set: [deleted_at: now])
  end

  def list_members(queryable \\ Organization, name_pattern \\ nil) do
    queryable
    |> Ecto.assoc(:members)
    |> with_member_name(name_pattern)
    |> active()
    |> join(:inner, [m], a in assoc(m, :account))
    |> preload(:account)
    |> order_by([_, a], a.name)
    |> Repo.all()
  end

  def list_members_by_ids(%Organization{} = organization, ids) when is_list(ids) do
    organization
    |> Ecto.assoc(:members)
    |> where([q], q.id in ^ids)
    |> Repo.all()
  end

  def members_count(queryable \\ Organization) do
    queryable
    |> Ecto.assoc(:members)
    |> Repo.count()
  end

  def get_member!(%Organization{} = organization, member_id) do
    organization
    |> Ecto.assoc(:members)
    |> preload([:account, :teams])
    |> Repo.get!(member_id)
  end

  def get_member!(member_id) do
    Member
    |> preload([:account, :teams])
    |> Repo.get!(member_id)
  end

  def get_member_from_account(%Organization{} = organization, %Account{} = account) do
    account
    |> Ecto.assoc(:members)
    |> preload([:account, :teams])
    |> where(organization_id: ^organization.id)
    |> Repo.one()
  end

  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.create_changeset(attrs)
    |> Repo.insert()
  end

  def delete_member(member) do
    member
    |> cast(%{deleted_at: DateTime.utc_now()}, [:deleted_at])
    |> Repo.update()
  end

  def update_administrators(organization, administrators_ids) do
    admins_scope =
      from(m in Organizations.Member,
        where: m.organization_id == ^organization.id and m.id in ^administrators_ids
      )

    members_scope =
      from(m in Organizations.Member,
        where: m.organization_id == ^organization.id and m.id not in ^administrators_ids
      )

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:set_admins, admins_scope, set: [role: "owner"])
    |> Ecto.Multi.update_all(:set_members, members_scope, set: [role: "member"])
    |> Repo.transaction()
  end

  def update_member_role(%Member{} = member, role) do
    member
    |> change(%{role: role})
    |> Repo.update()
  end

  def update_member_profile(%Member{} = member, attrs) do
    Member.update_profile_changeset(member, attrs)
    |> Repo.update()
  end

  def change_personal_information(%PersonalInformation{} = personal_information, attrs \\ %{}) do
    PersonalInformation.changeset(personal_information, attrs)
  end

  def create_personal_information(%Member{} = member, attrs) do
    PersonalInformation.changeset(%PersonalInformation{}, attrs)
    |> put_assoc(:member, member)
    |> Repo.insert()
  end

  @doc """
  List all informations of `member` that are visible to the `viewer`.

  It retrieves:

  - Public informations
  - Private informations where member == viewer
  - Private informations where viewer is in the members allow-list
  - Private informations where viewer is in the teams allow-list
  """
  def list_personal_informations(%Member{} = member, %Member{} = viewer) do
    query = """
    SELECT mi.*
    FROM personal_informations AS mi
    WHERE mi.private = 'false'
    AND mi.member_id = $1

    UNION

    SELECT mi.*
    FROM personal_informations AS mi
    WHERE mi.private = 'true'
    AND mi.member_id = $2
    AND mi.member_id = $3

    UNION

    SELECT mi.*
    FROM personal_informations AS mi
    JOIN personal_information_visibilities miv ON mi.id = miv.personal_information_id
    WHERE mi.member_id = $4
    AND mi.private = 'true'
    AND (miv.member_id = $5
    OR miv.team_id IN (
      SELECT DISTINCT tm.team_id
      FROM teams_members AS tm
      WHERE tm.member_id = $6
    ))
    """

    {:ok, member_id} = Ecto.UUID.dump(member.id)
    {:ok, viewer_id} = Ecto.UUID.dump(viewer.id)

    Repo.query!(query, [
      member_id,
      member_id,
      viewer_id,
      member_id,
      viewer_id,
      viewer_id
    ])
    |> Repo.load_raw(PersonalInformation)
    |> Repo.preload([:teams, :members])
    |> Enum.sort(fn info1, info2 -> Timex.before?(info1.inserted_at, info2.inserted_at) end)
  end

  def get_personal_information!(id) do
    PersonalInformation
    |> preload([:attachments, :teams, :members])
    |> Repo.get!(id)
  end

  def update_personal_information(personal_information, attrs) do
    PersonalInformation.changeset(personal_information, attrs)
    |> Repo.update()
  end

  def delete_personal_information(%PersonalInformation{} = personal_information) do
    Repo.delete(personal_information)
  end
end
