defmodule Palapa.Repo.Migrations.AddRoleToMemberships do
  use Ecto.Migration

  def up do
    Palapa.Organizations.RoleEnum.create_type()

    alter table(:memberships) do
      add(:role, :role, default: "member")
    end
  end

  def down do
    alter table(:memberships) do
      remove(:role)
    end

    Palapa.Organizations.RoleEnum.drop_type()
  end
end
