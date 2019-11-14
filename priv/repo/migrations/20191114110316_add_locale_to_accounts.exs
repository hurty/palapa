defmodule Palapa.Repo.Migrations.AddLocaleToAccounts do
  use Ecto.Migration

  def change do
    alter(table(:accounts)) do
      add(:locale, :string)
    end
  end
end
