defmodule Palapa.Repo.Migrations.CreateDocumentSuggestion do
  use Ecto.Migration

  def change do
    create table(:document_suggestions) do
      add(:page_id, references(:pages, on_delete: :delete_all), null: false)

      add(:content, :text)

      timestamps()
      add(:author_id, references(:members, on_delete: :nilify_all, null: false))
      add(:parent_suggestion_id, references(:document_suggestions, on_delete: :delete_all))
    end

    create(index(:document_suggestions, :page_id))
    create(index(:document_suggestions, :inserted_at))
    create(index(:document_suggestions, :author_id))
    create(index(:document_suggestions, :parent_suggestion_id))
  end
end
