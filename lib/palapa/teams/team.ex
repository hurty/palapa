defmodule Palapa.Teams.Team do
  use Palapa.Schema
  import Palapa.Gettext

  alias Palapa.Organizations
  alias Palapa.Teams.{Team, TeamMember}
  alias Palapa.Messages.{Message}

  schema "teams" do
    field(:name, :string)
    field(:private, :boolean)
    field(:deleted_at, :utc_datetime)
    timestamps()

    belongs_to(:organization, Organizations.Organization)
    many_to_many(:members, Organizations.Member, join_through: TeamMember, on_replace: :delete)
    many_to_many(:messages, Message, join_through: "messages_teams")
  end

  def changeset(%Team{} = team, attrs) do
    team
    |> cast(attrs, [:name, :private])
    |> validate_required([:name])
    |> unsafe_validate_unique(
      [:name, :organization_id],
      Palapa.Repo,
      message: gettext("This team already exists")
    )
  end

  def create_changeset(%Team{} = team, attrs) do
    team
    |> changeset(attrs)
    |> cast(attrs, [:organization_id])
    |> validate_required([:organization_id])
    |> foreign_key_constraint(:organization_id)
  end

  def put_members(changeset, members) do
    if Enum.empty?(members) do
      add_error(changeset, :members, gettext("Choose at least one member"))
    else
      put_assoc(changeset, :members, members)
    end
  end
end

defimpl Jason.Encoder, for: Palapa.Teams.Team do
  def encode(team, opts) do
    members_ids = Enum.map(team.members, & &1.id)
    team = Map.put(team, :members_ids, members_ids)
    Jason.Encode.map(Map.take(team, [:id, :name, :private, :members_ids]), opts)
  end
end
