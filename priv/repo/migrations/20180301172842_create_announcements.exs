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
      add(:published_to_everyone, :boolean, null: false, default: true)
    end

    create(index(:announcements, [:organization_id]))
    create(index(:announcements, [:creator_id]))
    create(index(:announcements, [:inserted_at]))

    create table(:announcements_teams, primary_key: false) do
      add(
        :announcement_id,
        references(:announcements, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:team_id, references(:teams, on_delete: :delete_all, type: :uuid), null: false)
    end

    create(index(:announcements_teams, [:announcement_id]))
    create(index(:announcements_teams, [:team_id]))
    create(unique_index(:announcements_teams, [:announcement_id, :team_id]))
  end
end
