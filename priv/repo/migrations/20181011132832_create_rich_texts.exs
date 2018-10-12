defmodule Palapa.Repo.Migrations.CreateRichTexts do
  use Ecto.Migration

  def change do
    create(table(:rich_texts, primary_key: false)) do
      add(:id, :uuid, primary_key: true)
      add(:body, :text)
      timestamps()

      add(:page_id, references(:pages, type: :uuid, on_delete: :delete_all))
    end

    create(index(:rich_texts, [:page_id]))
  end
end
