defmodule Palapa.Repo.Migrations.AddDeletedAtToMembers do
  use Ecto.Migration

  def change do
    alter(table(:members)) do
      add(:deleted_at, :utc_datetime)
    end
  end
end
