defmodule Palapa.Repo.Migrations.CreateAttachments do
  use Ecto.Migration

  def change do
    create table(:attachments, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(
        :organization_id,
        references(:organizations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:filename, :string, null: false)
      add(:content_type, :string)
      add(:byte_size, :integer)
      add(:checksum, :string)
      timestamps()
      add(:deleted_at, :utc_datetime, null: true, default: nil)
      add(:message_id, references(:messages, on_delete: :delete_all, type: :uuid))

      add(
        :message_comment_id,
        references(:messages_comments, on_delete: :delete_all, type: :uuid)
      )
    end

    create(index(:attachments, [:organization_id]))
    create(index(:attachments, [:deleted_at]))
    create(index(:attachments, [:message_id]))
    create(index(:attachments, [:message_comment_id]))
  end
end
