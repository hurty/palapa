defmodule Palapa.Teams.Policy do
  @behaviour Bodyguard.Policy
  alias Palapa.Accounts.User
  alias Palapa.Teams.Team
  alias Palapa.Repo, warn: false
  import Ecto.Query, warn: false

  # Owner can do anything
  def authorize(_, %User{role: :owner}, _), do: true

  # Admins can add a user to any team
  def authorize(:add_user, %User{role: :admin}, %Team{}), do: true

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
