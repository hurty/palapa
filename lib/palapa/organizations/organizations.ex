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

  def with_member_active(queryable \\ Member) do
    from(m in queryable, where: is_nil(m.deleted_at))
  end

  ### Actions

  def list_organizations(%Account{} = account) do
    Ecto.assoc(account, :organizations)
    |> active()
    |> order_by([o], o.name)
    |> Repo.all()
  end

  def get!(id) do
    Repo.get!(Organization, id)
  end

  def create(organization_attrs, creator_account) do
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

  def update_billing(%Organization{} = organization, attrs) do
    Organization.billing_changeset(organization, attrs)
    |> Repo.update()
  end

  def list_admins(organization) do
    organization
    |> Ecto.assoc(:members)
    |> where([m], m.role == "admin")
    |> join(:inner, [m], a in assoc(m, :account))
    |> order_by([_, a], a.name)
    |> Repo.all()
  end

  def list_members(queryable \\ Organization, name_pattern \\ nil) do
    queryable
    |> Ecto.assoc(:members)
    |> with_member_name(name_pattern)
    |> with_member_active()
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

  def update_member_profile(%Member{} = member, attrs) do
    Member.update_profile_changeset(member, attrs)
    |> Repo.update()
  end

  def change_personal_information(
        %PersonalInformation{} = personal_information \\ %PersonalInformation{},
        %Member{} = member,
        attrs \\ %{}
      ) do
    PersonalInformation.changeset(personal_information, member, attrs)
  end

  def create_personal_information(%Member{} = member, attrs) do
    PersonalInformation.changeset(%PersonalInformation{}, member, attrs)
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
    |> Repo.preload([:attachments, :teams, :members])
  end

  def get_personal_information!(id) do
    PersonalInformation
    |> preload([:attachments, :teams, :members])
    |> Repo.get!(id)
  end

  def update_personal_information(personal_information, attrs) do
    PersonalInformation.update_changeset(personal_information, attrs)
    |> Repo.update()
  end

  def delete_personal_information(%PersonalInformation{} = personal_information) do
    Repo.delete(personal_information)
  end
end
