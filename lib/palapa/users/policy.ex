defmodule Palapa.Users.Policy do
  @behaviour Bodyguard.Policy
  alias Palapa.Users.User
  alias Palapa.Organizations
  alias Palapa.Repo

  def authorize(:switch_organization, %User{} = user, organization) do
    user = user |> Repo.preload(:organizations, force: true)
    organization in user.organizations
  end

  # Owner can do anything
  def authorize(_, %User{role: :owner}, _), do: true

  # Anybody can see the list of users within an organization
  def authorize(:list, _, _), do: true

  # Anybody can see another user if they are in the same organization
  def authorize(:get_user, current_user, %{
        organization: organization,
        user: user
      }) do
    if user.id == current_user.id do
      true
    else
      Organizations.member?(organization, user)
    end
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
