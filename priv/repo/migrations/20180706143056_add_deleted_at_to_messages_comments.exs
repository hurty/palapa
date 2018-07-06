defmodule Palapa.Repo.Migrations.AddDeletedAtToMessagesComments do
  use Ecto.Migration

  def change do
    alter table(:messages_comments) do
      add(:deleted_at, :utc_datetime, null: true, default: nil)
    end

    create(index(:messages_comments, [:deleted_at]))
  end
end
