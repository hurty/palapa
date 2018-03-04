defmodule Palapa.Repo.Migrations.CreateAnnouncements do
  use Ecto.Migration

  def change do
    create table(:announcements, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(
        :organization_id,
        references(:organizations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:creator_id, references(:members, on_delete: :nilify_all, type: :uuid))
      timestamps()
      add(:title, :string, null: false)
      add(:content, :text)
    end

    create(index(:announcements, [:organization_id]))
    create(index(:announcements, [:creator_id]))
  end
end
