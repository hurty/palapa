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
    member
    |> Member.update_profile_changeset(attrs)
    |> Repo.update()
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

  def list_member_informations(%Member{} = member) do
    member
    |> Ecto.assoc(:member_informations)
    |> preload(:attachments)
    |> order_by([i], asc: i.type, asc: i.inserted_at)
    |> list
  end
end
