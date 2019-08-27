defmodule Palapa.Repo.Migrations.CreateResetPassword do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add(:password_reset_hash, :string)
      add(:password_reset_at, :utc_datetime)
    end

    create(unique_index(:accounts, :password_reset_hash))
  end
end
