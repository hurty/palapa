defmodule Palapa.Repo.Migrations.AddSendDailyRecapToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add(:send_daily_recap, :boolean, default: true)
    end
  end
end
