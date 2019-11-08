defmodule Palapa.Repo.Migrations.CreatePersonalInformations do
  use Ecto.Migration

  def change do
    create(table(:personal_informations, primary_key: false)) do
      add(:id, :uuid, primary_key: true)
      add(:member_id, references(:members, on_delete: :delete_all, type: :uuid), null: false)
      add(:label, :string, null: false)
      add(:value, :string)
      add(:private, :boolean, default: false)
      timestamps()
    end

    create(index(:personal_informations, [:member_id]))
  end
end
