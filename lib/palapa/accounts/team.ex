defmodule Palapa.Accounts.Team do
  use Ecto.Schema
  import Ecto.Changeset
  alias Palapa.Accounts.{Team, User, Organization, TeamUser}

  schema "teams" do
    field(:description, :string)
    field(:name, :string)
    field(:users_count, :integer, default: 0)
    timestamps()

    belongs_to(:organization, Organization)
    many_to_many(:users, User, join_through: TeamUser)
  end

  def changeset(%Team{} = team, attrs) do
    team
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end

  def create_changeset(%Team{} = team, attrs) do
    team
    |> changeset(attrs)
    |> cast(attrs, [:organization_id])
    |> validate_required([:organization_id])
    |> foreign_key_constraint(:organization_id)
  end
end
