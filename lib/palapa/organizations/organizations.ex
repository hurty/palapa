defmodule Palapa.Organizations do
  use Palapa.Context

  alias Organizations.{Organization, Member, MemberInformation}
  alias Palapa.Accounts.Account

  defdelegate(authorize(action, user, params), to: Palapa.Organizations.Policy)

  import EctoEnum
  defenum(RoleEnum, :role, [:owner, :admin, :member])

  @member_information_types [
    :custom,
    :phone,
    :email,
    :address,
    :birthday,
    :person_to_contact,
    :office_hours,
    :skype,
    :twitter,
    :facebook,
    :linkedin,
    :github
  ]

  def list_member_information_types do
    @member_information_types
  end

  # It seems that we can't use the module attribute @member_information_types in this EctoEnum macro,
  # so we're repeating types here.
  defenum(MemberInformationTypeEnum, :member_information_type, [
    :custom,
    :phone,
    :email,
    :skype,
    :address,
    :birthday,
    :person_to_contact,
    :office_hours,
    :twitter,
    :facebook,
    :linkedin,
    :github
  ])

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

  def list(queryable \\ Organization) do
    queryable
    |> Repo.all()
  end

  def get!(id) do
    Repo.get!(Organization, id)
  end

  def create(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  def delete(%Organization{} = organization) do
    Repo.delete(organization)
  end

  def change(%Organization{} = organization) do
    Organization.changeset(organization, %{})
  end

  def list_members(queryable \\ Organization, name_pattern \\ nil) do
    queryable
    |> Ecto.assoc(:members)
    |> with_member_name(name_pattern)
    |> preload(:account)
    |> Repo.all()
  end

  def list_members_by_ids(%Organization{} = organization, ids) when is_list(ids) do
    organization
    |> Ecto.assoc(:members)
    |> Access.scope_by_ids(ids)
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
    |> preload(:account)
    |> Repo.get!(member_id)
  end

  def get_member_from_account(%Organization{} = organization, %Account{} = account) do
    account
    |> Ecto.assoc(:members)
    |> preload(:account)
    |> where(organization_id: ^organization.id)
    |> Repo.one()
  end

  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  def update_member(%Member{} = member, attrs) do
    member = Repo.preload(member, :account)

    Account.changeset(member.account, attrs)
    |> Repo.update()

    # member
    # |> Member.update_profile_changeset(attrs)
    # |> Repo.update()
  end

  def member_change(%Member{} = member) do
    Member.update_profile_changeset(member, %{})
  end

  def change_member_information(
        %MemberInformation{} = member_information \\ %MemberInformation{},
        %Member{} = member,
        attrs \\ %{}
      ) do
    MemberInformation.changeset(member_information, member, attrs)
  end

  def create_member_information(%Member{} = member, attrs) do
    MemberInformation.changeset(%MemberInformation{}, member, attrs)
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
  def list_member_informations(%Member{} = member, %Member{} = viewer) do
    query = """
    SELECT mi.*
    FROM member_informations AS mi
    WHERE mi.private = 'false'
    AND mi.member_id = $1

    UNION

    SELECT mi.*
    FROM member_informations AS mi
    WHERE mi.private = 'true'
    AND mi.member_id = $2
    AND mi.member_id = $3

    UNION

    SELECT mi.*
    FROM member_informations AS mi
    JOIN member_information_visibilities miv ON mi.id = miv.member_information_id
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
    |> Repo.load_raw(MemberInformation)
    |> Repo.preload([:attachments, :teams, :members])
  end

  def get_member_information!(id) do
    MemberInformation
    |> preload([:attachments, :teams, :members])
    |> Repo.get!(id)
  end

  def update_member_information(member_information, attrs) do
    MemberInformation.update_changeset(member_information, attrs)
    |> Repo.update()
  end

  def delete_member_information(%MemberInformation{} = member_information) do
    Repo.delete(member_information)
  end
end
