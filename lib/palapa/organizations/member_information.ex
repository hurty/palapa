defmodule Palapa.Organizations.MemberInformation do
  use Palapa.Schema

  alias Palapa.Organizations.{Member, MemberInformationTypeEnum}
  alias Palapa.Attachments

  schema "member_informations" do
    belongs_to(:member, Member)
    field(:type, MemberInformationTypeEnum, default: :custom)
    field(:custom_label, :string)
    field(:value, :string)
    field(:private, :boolean, default: false)
    timestamps()
    has_many(:attachments, Attachments.Attachment, on_replace: :delete)
  end

  def changeset(%__MODULE__{} = member_information, %Member{} = member, attrs) do
    member_information
    |> cast(attrs, [:type, :custom_label, :value, :private])
    |> force_change(:member_id, member.id)
    |> put_attachments(attrs)
    |> validate_required([:member_id, :type, :value])
  end

  defp put_attachments(changeset, attrs) do
    if is_list(attrs["attachments"]) do
      attachments = Attachments.list_attachments_from_signed_ids(attrs["attachments"])
      put_assoc(changeset, :attachments, attachments)
    else
      changeset
    end
  end
end
