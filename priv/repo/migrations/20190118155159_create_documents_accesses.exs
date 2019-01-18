defmodule Palapa.Repo.Migrations.CreateDocumentsAccesses do
  use Ecto.Migration

  def change do
    create table(:documents_accesses) do
      add(:document_id, references(:documents), null: false)
      add(:member_id, references(:members), null: false)
      add(:last_access_at, :utc_datetime, null: false)
    end

    create(
      index(:documents_accesses, [:document_id, :member_id],
        unique: true,
        name: :document_access_uniqueness
      )
    )

    create(index(:documents_accesses, :document_id))
    create(index(:documents_accesses, :member_id))
    create(index(:documents_accesses, :last_access_at))
  end
end
