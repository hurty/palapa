defmodule Palapa.Teams.TeamUser do
  use Palapa.Schema

  alias Palapa.Teams.{Team, TeamUser}
  alias Palapa.Users.User

  @primary_key false
  schema "teams_users" do
    belongs_to(:team, Team)
    belongs_to(:user, User)
    timestamps()
  end

  def changeset(%TeamUser{} = team_user, attrs) do
    team_user
    |> cast(attrs, [:team_id, :user_id])
    |> validate_required([:team_id, :user_id])
    |> unique_constraint(:team_id, name: "teams_users_team_id_user_id_index")
  end
end
