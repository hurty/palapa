defmodule Palapa.Repo.Migrations.AddSoftDeleteToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add(:deleted_at, :utc_datetime)
    end

    create(index(:accounts, [:deleted_at]))
  end
end
