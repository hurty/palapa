defmodule Palapa.Repo.Migrations.CreateMemberInformations do
  use Ecto.Migration

  def change do
    Palapa.Organizations.MemberInformationTypeEnum.create_type()

    create(table(:member_informations, primary_key: false)) do
      add(:id, :uuid, primary_key: true)
      add(:member_id, references(:members, on_delete: :delete_all, type: :uuid), null: false)
      add(:type, :member_information_type)
      add(:custom_label, :string)
      add(:value, :string)
      add(:private, :boolean, default: false)
    end

    create(index(:member_informations, [:member_id]))
  end
end
