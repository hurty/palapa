defmodule Palapa.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(
        :organization_id,
        references(:organizations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:email, :string, null: false)
      add(:creator_id, references(:members, on_delete: :nilify_all, type: :uuid))
      timestamps()
      add(:email_sent_at, :utc_datetime)
      add(:expire_at, :utc_datetime)
      add(:token, :string)
    end

    create(index(:invitations, [:organization_id]))
    create(index(:invitations, [:email]))
    create(unique_index(:invitations, [:organization_id, :email]))
  end
end
