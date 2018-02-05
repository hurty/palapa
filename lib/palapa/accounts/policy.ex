defmodule Palapa.Accounts.Policy do
  @behaviour Bodyguard.Policy
  alias Palapa.Accounts.{Organization, User, Membership, Team, TeamUser}, warn: false
  alias Palapa.Repo, warn: false
  import Ecto.Query, warn: false

  def authorize(:switch_organization, %User{} = user, organization) do
    organization in user.organizations
  end

  # Owner can do anything
  def authorize(_, %User{role: :owner}, _), do: true

  # Anybody can see the list of users and teams
  def authorize(:list_users_and_teams, _, _), do: true

  # Admins can add a user to any team
  def authorize(:add_user_to_team, %User{role: :admin}, %Team{}), do: true

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
