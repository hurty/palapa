defmodule Palapa.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def up do
    Palapa.Events.EventActionEnum.create_type()

    create(table(:events)) do
      add(:organization_id, references(:organizations, on_delete: :delete_all), null: false)
      add(:author_id, references(:members, on_delete: :delete_all, null: false))
      add(:action, :event_action)
      timestamps(updated_at: false)
      add(:message_id, references(:messages, on_delete: :delete_all))
      add(:message_comment_id, references(:message_comments, on_delete: :delete_all))
      add(:document_id, references(:documents, on_delete: :delete_all))
      add(:page_id, references(:pages, on_delete: :delete_all))
      add(:document_suggestion_id, references(:document_suggestions, on_delete: :delete_all))

      add(
        :document_suggestion_comment_id,
        references(:document_suggestion_comments, on_delete: :delete_all)
      )
    end

    create(index(:events, :organization_id))
    create(index(:events, :author_id))
    create(index(:events, :message_id))
    create(index(:events, :message_comment_id))
    create(index(:events, :document_id))
    create(index(:events, :page_id))
    create(index(:events, :document_suggestion_id))
    create(index(:events, :document_suggestion_comment_id))
    create(index(:events, :inserted_at))
  end

  def down do
    drop(table(:events))
    Palapa.Events.EventActionEnum.drop_type()
  end
end
