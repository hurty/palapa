defmodule Palapa.Repo.Migrations.CreateMemberInformations do
  use Ecto.Migration

  def up do
    Palapa.Organizations.MemberInformationTypeEnum.create_type()

    create(table(:member_informations, primary_key: false)) do
      add(:id, :uuid, primary_key: true)
      add(:member_id, references(:members, on_delete: :delete_all, type: :uuid), null: false)
      add(:type, :member_information_type)
      add(:custom_label, :string)
      add(:value, :string)
      add(:private, :boolean, default: false)
      timestamps()
    end

    create(index(:member_informations, [:member_id]))

    alter(table(:attachments)) do
      add(
        :member_information_id,
        references(:member_informations, on_delete: :delete_all, type: :uuid)
      )
    end

    create(index(:attachments, :member_information_id))
  end

  def down do
    drop(table(:member_informations))
    Palapa.Organizations.MemberInformationTypeEnum.drop_type()

    # alter(table(:attachments)) do
    #   remove(:member_information_id)
    # end
  end
end
