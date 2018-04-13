defmodule Palapa.Repo.Migrations.AddDeletedAtToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add(:deleted_at, :utc_datetime, null: true, default: nil)
    end

    create(index(:messages, [:deleted_at]))
  end
end
