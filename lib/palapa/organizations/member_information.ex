defmodule Palapa.Organizations.MemberInformation do
  use Palapa.Schema

  alias Palapa.Organizations.{Member, MemberInformationTypeEnum}
  alias Palapa.Teams.Team
  alias Palapa.Attachments

  schema "member_informations" do
    belongs_to(:member, Member)
    field(:type, MemberInformationTypeEnum)
    field(:custom_label, :string)
    field(:value, :string)
    field(:private, :boolean, default: false)
    timestamps()
    has_many(:attachments, Attachments.Attachment, on_replace: :delete)

    many_to_many(:teams, Team,
      join_through: "member_information_visibilities",
      on_delete: :delete_all,
      on_replace: :delete
    )

    many_to_many(:members, Member,
      join_through: "member_information_visibilities",
      on_delete: :delete_all,
      on_replace: :delete
    )

    field(:visibilities, {:array, :string}, virtual: true)
  end

  def changeset(%__MODULE__{} = member_information, %Member{} = member, attrs) do
    member_information
    |> cast(attrs, [:type, :custom_label, :value, :private, :visibilities])
    |> force_change(:member_id, member.id)
    |> put_attachments(attrs)
    |> put_teams
    |> put_members
    |> validate_required([:member_id, :type, :value])
    |> validate_custom_information
  end

  def update_changeset(%__MODULE__{} = member_information, attrs) do
    member_information
    |> cast(attrs, [:type, :custom_label, :value, :private, :visibilities])
    |> put_attachments(attrs)
    |> put_teams
    |> put_members
    |> put_visibilities(member_information)
    |> validate_required([:type, :value])
    |> validate_custom_information
  end

  def put_visibilities(changeset, member_information) do
    teams_sids =
      member_information.teams
      |> Enum.map(fn team -> to_string(Palapa.Access.GlobalId.create("palapa", team)) end)

    members_sids =
      member_information.members
      |> Enum.map(fn member -> to_string(Palapa.Access.GlobalId.create("palapa", member)) end)

    put_change(changeset, :visibilities, teams_sids ++ members_sids)
  end

  defp put_attachments(changeset, attrs) do
    if is_list(attrs["attachments"]) do
      attachments = Attachments.list_attachments_from_signed_ids(attrs["attachments"])
      put_assoc(changeset, :attachments, attachments)
    else
      changeset
    end
  end

  defp put_teams(changeset) do
    visibilities = get_change(changeset, :visibilities)

    if visibilities do
      teams = Palapa.Access.GlobalId.locate_all(visibilities, Palapa.Teams.Team)
      put_assoc(changeset, :teams, teams)
    else
      changeset
    end
  end

  defp put_members(changeset) do
    visibilities = get_change(changeset, :visibilities)

    if visibilities do
      members = Palapa.Access.GlobalId.locate_all(visibilities, Palapa.Organizations.Member)

      put_assoc(changeset, :members, members)
    else
      changeset
    end
  end

  defp validate_custom_information(changeset) do
    case get_field(changeset, :type) do
      :custom -> validate_required(changeset, [:custom_label])
      _ -> changeset
    end
  end
end
