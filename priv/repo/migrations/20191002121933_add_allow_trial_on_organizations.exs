defmodule Palapa.Repo.Migrations.AddAllowTrialOnOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add(:allow_trial, :boolean, null: false, default: false)
    end
  end
end
