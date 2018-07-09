defmodule Palapa.Repo.Migrations.AddPrivateToTeams do
  use Ecto.Migration

  def change do
    alter(table(:teams)) do
      add(:private, :boolean, null: false, default: false)
    end
  end
end
