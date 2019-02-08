defmodule Palapa.Repo.Migrations.CreateDocumentSuggestion do
  use Ecto.Migration

  def change do
    create table(:document_suggestions) do
      add(:organization_id, references(:organizations, on_delete: :delete_all), null: false)
      add(:page_id, references(:pages, on_delete: :delete_all), null: false)

      add(:content, :text)

      timestamps()
      add(:author_id, references(:members, on_delete: :nilify_all, null: false))
      add(:parent_suggestion_id, references(:document_suggestions, on_delete: :delete_all))
      add(:closed_at, :utc_datetime)
      add(:closure_author_id, references(:members, on_delete: :nilify_all))
    end

    create(index(:document_suggestions, :organization_id))
    create(index(:document_suggestions, :page_id))
    create(index(:document_suggestions, :inserted_at))
    create(index(:document_suggestions, :author_id))
    create(index(:document_suggestions, :parent_suggestion_id))
    create(index(:document_suggestions, :closure_author_id))

    create table(:document_suggestion_comments) do
      add(:organization_id, references(:organizations, on_delete: :delete_all), null: false)
      add(:suggestion_id, references(:document_suggestions, on_delete: :delete_all), null: false)

      add(:content, :text)
      add(:author_id, references(:members, on_delete: :nilify_all, null: false))
      timestamps()
    end

    create(index(:document_suggestion_comments, :organization_id))
    create(index(:document_suggestion_comments, :suggestion_id))
    create(index(:document_suggestion_comments, :inserted_at))
    create(index(:document_suggestion_comments, :author_id))
  end
end
