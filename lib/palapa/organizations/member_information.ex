defmodule Palapa.Organizations.MemberInformation do
  use Palapa.Schema
  alias Palapa.Organizations.{Member, MemberInformationTypeEnum}

  schema "member_informations" do
    belongs_to(:member, Member)
    field(:type, MemberInformationTypeEnum, default: :custom)
    field(:custom_label, :string)
    field(:value, :string)
    field(:private, :boolean, default: false)
    timestamps()
  end

  def changeset(%__MODULE__{} = member_information, %Member{} = member, attrs) do
    member_information
    |> cast(attrs, [:type, :custom_label, :value, :private])
    |> force_change(:member_id, member.id)
    |> validate_required([:member_id, :type, :value])
  end
end
