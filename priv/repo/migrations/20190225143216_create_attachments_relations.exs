defmodule Palapa.Repo.Migrations.CreateAttachmentsRelations do
  use Ecto.Migration

  def change do
    create table(:personal_information_attachments, primary_key: false) do
      add(:personal_information_id, references(:personal_informations, on_delete: :delete_all))
      add(:attachment_id, references(:attachments, on_delete: :delete_all))
    end

    create(index(:personal_information_attachments, [:personal_information_id]))
    create(index(:personal_information_attachments, [:attachment_id]))

    create table(:messages_attachments, primary_key: false) do
      add(:message_id, references(:messages, on_delete: :delete_all))
      add(:attachment_id, references(:attachments, on_delete: :delete_all))
    end

    create(index(:messages_attachments, [:message_id]))
    create(index(:messages_attachments, [:attachment_id]))

    create table(:message_comments_attachments, primary_key: false) do
      add(:message_comment_id, references(:message_comments, on_delete: :delete_all))
      add(:attachment_id, references(:attachments, on_delete: :delete_all))
    end

    create(index(:message_comments_attachments, [:message_comment_id]))
    create(index(:message_comments_attachments, [:attachment_id]))

    create table(:pages_attachments, primary_key: false) do
      add(:page_id, references(:pages, on_delete: :delete_all))
      add(:attachment_id, references(:attachments, on_delete: :delete_all))
    end

    create(index(:pages_attachments, [:page_id]))
    create(index(:pages_attachments, [:attachment_id]))

    create table(:document_suggestions_attachments, primary_key: false) do
      add(:document_suggestion_id, references(:document_suggestions, on_delete: :delete_all))
      add(:attachment_id, references(:attachments, on_delete: :delete_all))
    end

    create(index(:document_suggestions_attachments, [:document_suggestion_id]))
    create(index(:document_suggestions_attachments, [:attachment_id]))

    create table(:document_suggestion_comments_attachments, primary_key: false) do
      add(
        :document_suggestion_comment_id,
        references(:document_suggestion_comments, on_delete: :delete_all)
      )

      add(:attachment_id, references(:attachments, on_delete: :delete_all))
    end

    create(index(:document_suggestion_comments_attachments, [:document_suggestion_comment_id]))
    create(index(:document_suggestion_comments_attachments, [:attachment_id]))
  end
end
