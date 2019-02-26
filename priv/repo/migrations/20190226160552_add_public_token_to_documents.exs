defmodule Palapa.Repo.Migrations.AddPublicTokenToDocuments do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add(:public_token, :string, default: nil)
    end

    create(index(:documents, [:public_token]))
  end
end
