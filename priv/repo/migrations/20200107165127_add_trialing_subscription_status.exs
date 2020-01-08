defmodule Palapa.Repo.Migrations.AddTrialingSubscriptionStatus do
  use Ecto.Migration

  @disable_ddl_transaction true

  def up do
    Ecto.Migration.execute("ALTER TYPE subscription_status ADD VALUE IF NOT EXISTS 'trialing'")
  end

  def down do
  end
end
