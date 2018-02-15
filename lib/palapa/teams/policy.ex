defmodule Palapa.Teams.Policy do
  @behaviour Bodyguard.Policy

  alias Palapa.Organizations.Member
  alias Palapa.Repo, warn: false
  import Ecto.Query, warn: false

  def authorize(:edit_user_teams, %Member{role: role}, _params) do
    role in [:owner, :admin]
  end

  def authorize(:update_user_teams, %Member{role: role}, _params) do
    role in [:owner, :admin]
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
