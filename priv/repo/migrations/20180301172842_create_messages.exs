defmodule Palapa.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
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

    create(index(:messages, [:organization_id]))
    create(index(:messages, [:creator_id]))
    create(index(:messages, [:inserted_at]))

    create table(:messages_teams, primary_key: false) do
      add(
        :message_id,
        references(:messages, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:team_id, references(:teams, on_delete: :delete_all, type: :uuid), null: false)
    end

    create(index(:messages_teams, [:message_id]))
    create(index(:messages_teams, [:team_id]))
    create(unique_index(:messages_teams, [:message_id, :team_id]))
  end
end
