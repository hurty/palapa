defmodule Palapa.Repo.Migrations.AddCreatorToOrganizations do
  use Ecto.Migration

  def change do
    alter(table(:organizations)) do
      add(:creator_account_id, references(:accounts, on_delete: :nilify_all))
      add(:deleted_at, :utc_datetime_usec)
      add(:deleted_by_account_id, references(:accounts, on_delete: :nilify_all))
    end

    create(index(:organizations, :creator_account_id))
    create(index(:organizations, :deleted_at))
    create(index(:organizations, :deleted_by_account_id))
  end
end
