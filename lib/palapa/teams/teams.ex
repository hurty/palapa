defmodule Palapa.Teams do
  use Palapa.Context

  alias Palapa.Teams.{Team, TeamUser}
  alias Palapa.Users
  alias Palapa.Users.User
  alias Palapa.Organizations.Organization

  defdelegate(authorize(action, user, params), to: Palapa.Teams.Policy)

  def get!(id), do: Repo.get!(Team, id)

  def list(queryable \\ Team, %Organization{} = organization) do
    queryable
    |> Access.scope(organization)
    |> order_by(:name)
    |> Repo.all()
  end

  def list_by_ids(queryable \\ Team, %Organization{} = organization, teams_ids) do
    queryable
    |> where([t], t.id in ^teams_ids)
    |> list(organization)
  end

  def list_users(%Team{} = team) do
    team
    |> Ecto.assoc(:users)
    |> order_by(:name)
    |> Repo.all()
  end

  def list_for_user(%Organization{} = organization, %User{} = user) do
    user
    |> Ecto.assoc(:teams)
    |> Access.scope(organization)
    |> order_by(:name)
    |> Repo.all()
  end

  def create(%Organization{} = organization, attrs \\ %{}) do
    team_attrs = Map.merge(attrs, %{organization_id: organization.id})

    %Team{}
    |> Team.create_changeset(team_attrs)
    |> Repo.insert()
  end

  def update(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  def delete(%Team{} = team) do
    Repo.delete(team)
  end

  def change(%Team{} = team) do
    Team.changeset(team, %{})
  end

  def add_user(%Team{} = team, %User{} = user) do
    TeamUser.changeset(%TeamUser{}, %{user_id: user.id, team_id: team.id})
    |> increment_counter_cache(team, :users_count)
    |> Repo.insert()
    |> case do
      {:ok, team_user} ->
        {:ok, Repo.get(Team, team_user.team_id)}

      {_, details} ->
        {:error, details}
    end
  end

  def remove_user(%Team{} = team, %User{} = user) do
    team_user_query =
      from(tu in TeamUser, where: tu.user_id == ^user.id and tu.team_id == ^team.id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:team_user, team_user_query)
    |> Ecto.Multi.run(:counter_cache_decrement, fn changes_so_far ->
      # Avoids having a negative counter by checking if the row has actually been deleted
      %{team_user: {deleted_entries_count, nil}} = changes_so_far

      if deleted_entries_count > 0 do
        Repo.decrement(team, :users_count)
      else
        {:ok, team}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        {:ok, Repo.reload(team)}

      {_, details} ->
        {:error, details}
    end
  end

  def member?(%Team{} = team, %User{} = user) do
    TeamUser
    |> where(user_id: ^user.id, team_id: ^team.id)
    |> Repo.exists?()
  end

  def update_for_user(%User{} = user, teams) do
    Users.change(user)
    |> Repo.preload(:teams)
    |> Ecto.Changeset.put_assoc(:teams, teams)
    |> Repo.update()
  end

  defp increment_counter_cache(changeset, struct, counter_name, value \\ 1) do
    prepare_changes(changeset, fn prepared_changeset ->
      prepared_changeset.repo.increment(struct, counter_name, value)
      prepared_changeset
    end)
  end
end
