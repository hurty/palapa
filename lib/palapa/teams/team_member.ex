defmodule Palapa.Teams.TeamMember do
  use Palapa.Schema

  alias Palapa.Organizations.Member
  alias Palapa.Teams.{Team, TeamMember}

  @primary_key false
  schema "teams_members" do
    belongs_to(:team, Team)
    belongs_to(:member, Member)
    timestamps()
  end

  def changeset(%TeamMember{} = team_member, attrs) do
    team_member
    |> cast(attrs, [:team_id, :member_id])
    |> validate_required([:team_id, :member_id])
    |> unique_constraint(:team_id, name: "teams_members_team_id_member_id_index")
  end
end
