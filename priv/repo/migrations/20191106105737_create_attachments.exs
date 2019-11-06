defmodule Palapa.Repo.Migrations.CreateAttachments do
  use Ecto.Migration

  def change do
    Palapa.Attachments.AttachableTypeEnum.create_type()

    create table(:attachments) do
      timestamps()

      add(
        :organization_id,
        references(:organizations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:filename, :string, null: false)
      add(:content_type, :string)
      add(:byte_size, :integer)
      add(:checksum, :string)
      add(:deleted_at, :utc_datetime, null: true, default: nil)
      add(:creator_id, references(:members, on_delete: :nilify_all, type: :uuid))
      # Attachables

      add(:attachable_type, :attachable_type)
      add(:personal_information_id, references(:personal_informations, on_delete: :delete_all))
      add(:message_id, references(:messages, on_delete: :delete_all))
      add(:message_comment_id, references(:message_comments, on_delete: :delete_all))
      add(:page_id, references(:pages, on_delete: :delete_all))
      add(:document_suggestion_id, references(:document_suggestions, on_delete: :delete_all))

      add(
        :document_suggestion_comment_id,
        references(:document_suggestion_comments, on_delete: :delete_all)
      )

      add(:contact_comment_id, references(:contact_comments, on_delete: :delete_all))
    end

    create(index(:attachments, [:organization_id]))
    create(index(:attachments, [:deleted_at]))
    create(index(:attachments, [:creator_id]))

    create(index(:attachments, [:personal_information_id]))
    create(index(:attachments, [:message_id]))
    create(index(:attachments, [:message_comment_id]))
    create(index(:attachments, [:page_id]))
    create(index(:attachments, [:document_suggestion_comment_id]))
    create(index(:attachments, [:contact_comment_id]))
  end
end
