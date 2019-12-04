defmodule Palapa.Repo.Migrations.AddInvitationToBetaSubscriptions do
  use Ecto.Migration

  def change do
    alter(table(:beta_subscriptions)) do
      add(:invitation, :string)
      add(:used, :boolean, default: false)
    end
  end
end
