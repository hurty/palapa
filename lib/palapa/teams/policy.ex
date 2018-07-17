defmodule Palapa.Teams.Policy do
  use Palapa.Policy

  def authorize(:create, %Member{role: role}, _params) do
    role in [:owner, :admin]
  end

  def authorize(:edit, %Member{role: role}, _params) do
    role in [:owner, :admin]
  end

  def authorize(:update, %Member{role: role}, _params) do
    role in [:owner, :admin]
  end

  def authorize(:edit_member_teams, %Member{role: role}, _params) do
    role in [:owner, :admin]
  end

  def authorize(:update_member_teams, %Member{role: role}, _params) do
    role in [:owner, :admin]
  end

  def authorize(:join, %Member{role: role}, team) do
    !team.private || role in [:owner, :admin]
  end

  def authorize(:leave, %Member{}, _team) do
    true
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
