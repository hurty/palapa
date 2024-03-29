defmodule Palapa.Repo.Migrations.CreateContactComments do
  use Ecto.Migration

  def change do
    create table(:contact_comments) do
      add(
        :organization_id,
        references(:organizations, on_delete: :delete_all),
        null: false
      )

      add(:contact_id, references(:contacts, on_delete: :delete_all), null: false)
      add(:author_id, references(:members, on_delete: :nilify_all), null: false)
      timestamps()
      add(:content, :text)
    end

    create(index(:contact_comments, [:organization_id]))
    create(index(:contact_comments, [:contact_id]))
    create(index(:contact_comments, [:author_id]))
    create(index(:contact_comments, [:inserted_at]))

    alter(table(:events)) do
      add(:contact_comment_id, references(:contact_comments, on_delete: :delete_all))
    end

    create(index(:events, :contact_comment_id))
  end
end
