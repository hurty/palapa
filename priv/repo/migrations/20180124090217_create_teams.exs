defmodule Palapa.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(
        :organization_id,
        references(:organizations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:name, :string, null: false)
      add(:members_count, :integer, null: false, default: 0)
      timestamps()
    end

    create(index(:teams, [:organization_id]))
  end
end
