defmodule Palapa.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:email, :string, null: false)
      add(:password_hash, :string, null: false)
      add(:name, :string, null: false)
      add(:avatar, :string)

      timestamps()
    end

    create(unique_index(:accounts, :email))
  end
end
