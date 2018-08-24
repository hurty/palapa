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
  end

  def changeset(%__MODULE__{} = member_information, %Member{} = member, attrs) do
    member_information
    |> cast(attrs, [:type, :custom_label, :value, :private])
    |> force_change(:member_id, member.id)
    |> put_attachments(attrs)
    |> put_teams_visibilities(attrs)
    |> put_members_visibilities(attrs)
    |> validate_required([:member_id, :type, :value])
    |> validate_custom_information
  end

  defp put_attachments(changeset, attrs) do
    if is_list(attrs["attachments"]) do
      attachments = Attachments.list_attachments_from_signed_ids(attrs["attachments"])
      put_assoc(changeset, :attachments, attachments)
    else
      changeset
    end
  end

  defp put_teams_visibilities(changeset, attrs) do
    if attrs["teams"] do
      put_assoc(changeset, :teams, attrs["teams"])
    else
      changeset
    end
  end

  defp put_members_visibilities(changeset, attrs) do
    if attrs["members"] do
      put_assoc(changeset, :members, attrs["members"])
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
