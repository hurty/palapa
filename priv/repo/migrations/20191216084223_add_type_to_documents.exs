defmodule Palapa.Repo.Migrations.AddTypeToDocuments do
  use Ecto.Migration

  alias Palapa.Documents.DocumentTypeEnum

  @disable_ddl_transaction true

  def up do
    DocumentTypeEnum.create_type()

    alter(table(:documents)) do
      add(:type, DocumentTypeEnum.type(), null: false, default: "internal")
      add(:link, :string)
    end

    Ecto.Migration.execute("ALTER TYPE attachable_type ADD VALUE IF NOT EXISTS 'document'")

    alter(table(:attachments)) do
      add(:document_id, references(:documents, on_delete: :delete_all))
    end

    create(index(:attachments, :document_id))
  end

  def down do
    alter(table(:documents)) do
      remove(:type)
      remove(:link)
    end

    DocumentTypeEnum.drop_type()

    alter(table(:attachments)) do
      remove(:document_id)
    end
  end
end
