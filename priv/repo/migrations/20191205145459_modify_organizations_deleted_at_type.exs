defmodule Palapa.Repo.Migrations.ModifyOrganizationsDeletedAtType do
  use Ecto.Migration

  def change do
    alter(table(:organizations)) do
      modify(:deleted_at, :utc_datetime)
    end
  end
end
