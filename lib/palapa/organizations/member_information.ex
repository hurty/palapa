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

  def changeset(%__MODULE__{} = member_information, attrs) do
    member_information
    |> cast(attrs, [:member_id, :type, :custom_label, :value, :private])
    |> validate_required([:member_id, :type])
  end
end
