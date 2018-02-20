defmodule Palapa.Teams.Team do
  use Palapa.Schema

  alias Palapa.Organizations
  alias Palapa.Teams.{Team, TeamMember}

  schema "teams" do
    field(:name, :string)
    field(:members_count, :integer, default: 0)
    timestamps()

    belongs_to(:organization, Organizations.Organization)
    many_to_many(:members, Organizations.Member, join_through: TeamMember)
  end

  def changeset(%Team{} = team, attrs) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unsafe_validate_unique(
      [:name, :organization_id],
      Palapa.Repo,
      message: "This team already exists"
    )
  end

  def create_changeset(%Team{} = team, attrs) do
    team
    |> changeset(attrs)
    |> cast(attrs, [:organization_id])
    |> validate_required([:organization_id])
    |> foreign_key_constraint(:organization_id)
  end
end
