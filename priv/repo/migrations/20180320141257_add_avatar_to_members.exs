defmodule Palapa.Repo.Migrations.AddAvatarToAccounts do
  use Ecto.Migration

  def change do
    alter table("members") do
      add(:avatar, :string)
    end
  end
end
