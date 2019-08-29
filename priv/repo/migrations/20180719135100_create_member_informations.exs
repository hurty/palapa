defmodule Palapa.Repo.Migrations.CreateMemberInformations do
  use Ecto.Migration

  def change do
    create(table(:member_informations, primary_key: false)) do
      add(:id, :uuid, primary_key: true)
      add(:member_id, references(:members, on_delete: :delete_all, type: :uuid), null: false)
      add(:label, :string, null: false)
      add(:value, :string, null: false)
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
end
