defmodule Palapa.Repo.Migrations.CreateBetaSubscriptions do
  use Ecto.Migration

  def change do
    create(table(:beta_subscriptions)) do
      add(:email, :string, null: false)
      add(:beta, :boolean, default: false)
      timestamps()
    end

    create(unique_index(:beta_subscriptions, [:email]))
  end
end
