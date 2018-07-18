defmodule Palapa.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    Palapa.Organizations.RoleEnum.create_type()

    create table(:members, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:account_id, references(:accounts, on_delete: :delete_all, type: :uuid), null: false)

      add(
        :organization_id,
        references(:organizations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:role, :role, default: "member")
      add(:title, :string)
      timestamps()
    end

    create(index(:members, [:organization_id]))
    create(index(:members, [:account_id]))
    create(unique_index(:members, [:organization_id, :account_id]))
  end
end
