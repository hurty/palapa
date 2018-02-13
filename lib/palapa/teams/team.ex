defmodule Palapa.Teams.Team do
  use Palapa.Schema

  import Ecto.Query
  alias Palapa.Teams.{Team, TeamUser}
  alias Palapa.Users.User
  alias Palapa.Organizations.Organization

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

  def scope(query, %User{} = user, _) do
    from(
      t in query,
      join: tu in TeamUser,
      on: [team_id: t.id],
      where: tu.user_id == ^user.id
    )
  end
end
