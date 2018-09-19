defmodule Palapa.Repo.Migrations.AddCreatorToAttachments do
  use Ecto.Migration

  def change do
    alter table(:attachments) do
      add(:creator_id, references(:members, on_delete: :nilify_all, type: :uuid))
    end

    create(index(:attachments, [:creator_id]))
  end
end
