defmodule Palapa.Repo.Migrations.AddMessagesComments do
  use Ecto.Migration

  def change do
    create table(:message_comments, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(
        :organization_id,
        references(:organizations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:message_id, references(:messages, on_delete: :delete_all, type: :uuid), null: false)
      add(:creator_id, references(:members, on_delete: :nilify_all, type: :uuid))
      timestamps()
      add(:content, :text)
    end

    create(index(:message_comments, [:organization_id]))
    create(index(:message_comments, [:creator_id]))
    create(index(:message_comments, [:inserted_at]))
  end
end
