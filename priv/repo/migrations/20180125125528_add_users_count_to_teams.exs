defmodule Palapa.Repo.Migrations.AddUsersCountToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :users_count, :integer, null: false, default: 0
    end
  end
end
