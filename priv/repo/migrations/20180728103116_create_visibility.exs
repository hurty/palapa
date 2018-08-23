defmodule Palapa.Repo.Migrations.CreateVisibilities do
  use Ecto.Migration

  def change do
    create table(:member_information_visibilities, primary_key: false) do
      add(
        :member_information_id,
        references(:member_informations, on_delete: :delete_all, type: :uuid),
        null: false
      )

      add(:member_id, references(:members, on_delete: :delete_all, type: :uuid))
      add(:team_id, references(:teams, on_delete: :delete_all, type: :uuid))
    end

    create(index(:member_information_visibilities, [:team_id]))
    create(index(:member_information_visibilities, [:member_id]))
    create(index(:member_information_visibilities, [:member_information_id]))
    create(unique_index(:member_information_visibilities, [:team_id, :member_information_id]))
    create(unique_index(:member_information_visibilities, [:member_id, :member_information_id]))
  end
end
