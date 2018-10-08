defmodule Palapa.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    # --------- DOCUMENTS --------------

    create table(:documents, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(
        :organization_id,
        references(:organizations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:title, :string)
      timestamps()
      add(:public, :boolean, default: false, null: false)
      add(:last_author_id, references(:members, on_delete: :nilify_all, type: :uuid))
      add(:team_id, references(:teams, on_delete: :nilify_all, type: :uuid))
    end

    create(index(:documents, [:last_author_id]))
    create(index(:documents, [:team_id]))
    create(index(:documents, [:public]))
    create(index(:documents, [:organization_id]))

    # --------- SECTION --------------

    create table(:document_sections, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(
        :organization_id,
        references(:organizations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(
        :document_id,
        references(:documents, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:title, :string)
      timestamps()

      add(:last_author_id, references(:members, on_delete: :nilify_all, type: :uuid))
      add(:position, :integer, null: false, default: 0)
    end

    create(index(:document_sections, :organization_id))
    create(index(:document_sections, :document_id))
    create(index(:document_sections, :last_author_id))
    create(index(:document_sections, :position))

    # --------- PAGES --------------

    create table(:document_pages, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(
        :organization_id,
        references(:organizations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:document_id, references(:documents, on_delete: :delete_all, type: :uuid))

      add(
        :section_id,
        references(:document_sections, on_delete: :delete_all, type: :uuid)
      )

      add(:title, :string)
      timestamps()

      add(:last_author_id, references(:members, on_delete: :nilify_all, type: :uuid))
      add(:position, :integer, null: false, default: 0)
    end

    create(index(:document_pages, :organization_id))
    create(index(:document_pages, :section_id))
    create(index(:document_pages, :last_author_id))
    create(index(:document_pages, :position))

    alter table(:documents) do
      add(:first_page_id, references(:document_pages, on_delete: :nilify_all, type: :uuid))
    end

    create(index(:documents, :first_page_id))
  end
end
