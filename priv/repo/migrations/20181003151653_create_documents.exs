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
      add(:deleted_at, :utc_datetime, default: nil)
    end

    create(index(:documents, [:last_author_id]))
    create(index(:documents, [:team_id]))
    create(index(:documents, [:public]))
    create(index(:documents, [:organization_id]))
    create(index(:documents, [:deleted_at]))

    # --------- SECTION --------------

    create table(:sections, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(
        :document_id,
        references(:documents, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:title, :string)
      timestamps()

      add(:last_author_id, references(:members, on_delete: :nilify_all, type: :uuid))
      add(:position, :integer, null: true)
      add(:deleted_at, :utc_datetime, default: nil)
    end

    create(index(:sections, :document_id))
    create(index(:sections, :last_author_id))
    create(index(:sections, :position))
    create(index(:sections, :deleted_at))

    # --------- PAGES --------------

    create table(:pages, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:document_id, references(:documents, on_delete: :delete_all, type: :uuid))

      add(
        :section_id,
        references(:sections, on_delete: :delete_all, type: :uuid)
      )

      add(:title, :string)
      timestamps()

      add(:last_author_id, references(:members, on_delete: :nilify_all, type: :uuid))
      add(:position, :integer, null: true)
      add(:deleted_at, :utc_datetime, default: nil)
    end

    create(index(:pages, :document_id))
    create(index(:pages, :section_id))
    create(index(:pages, :last_author_id))
    create(index(:pages, :position))
    create(index(:pages, :deleted_at))

    alter table(:documents) do
      add(:main_section_id, references(:sections, on_delete: :nilify_all, type: :uuid))
      add(:main_page_id, references(:pages, on_delete: :nilify_all, type: :uuid))
    end

    create(index(:documents, :main_section_id))
    create(index(:documents, :main_page_id))
  end
end
