defmodule Palapa.Repo.Migrations.AddTimezones do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add(:default_timezone, :string)
    end

    alter table(:accounts) do
      add(:timezone, :string)
    end
  end
end
