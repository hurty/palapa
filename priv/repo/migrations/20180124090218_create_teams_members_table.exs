defmodule Palapa.Repo.Migrations.CreateTeamsMembersTable do
  use Ecto.Migration

  def change do
    create table(:teams_members, primary_key: false) do
      add(:team_id, references(:teams, on_delete: :delete_all, type: :uuid), null: false)
      add(:member_id, references(:members, on_delete: :delete_all, type: :uuid), null: false)
      timestamps()
    end

    create(index(:teams_members, [:team_id]))
    create(index(:teams_members, [:member_id]))
    create(unique_index(:teams_members, [:team_id, :member_id]))
  end
end
