defmodule Palapa.Repo.Migrations.CreateVisibilities do
  use Ecto.Migration

  def change do
    create table(:personal_information_visibilities, primary_key: false) do
      add(
        :personal_information_id,
        references(:personal_informations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:member_id, references(:members, on_delete: :delete_all, type: :uuid))
      add(:team_id, references(:teams, on_delete: :delete_all, type: :uuid))
    end

    create(index(:personal_information_visibilities, [:team_id]))
    create(index(:personal_information_visibilities, [:member_id]))
    create(index(:personal_information_visibilities, [:personal_information_id]))
    create(unique_index(:personal_information_visibilities, [:team_id, :personal_information_id]))
    create(unique_index(:personal_information_visibilities, [:member_id, :personal_information_id]))
  end
end
