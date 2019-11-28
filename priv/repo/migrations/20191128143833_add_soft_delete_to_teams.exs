defmodule Palapa.Repo.Migrations.AddSoftDeleteToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:deleted_at, :utc_datetime)
    end

    create(index(:teams, [:deleted_at]))
  end
end
