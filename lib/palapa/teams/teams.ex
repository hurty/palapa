defmodule Palapa.Teams do
  import Ecto.Query, warn: false
  import Ecto.Changeset, warn: false
  alias Palapa.Repo
  alias Palapa.Teams.{Team, TeamUser}
  alias Palapa.Accounts.{User, Organization}

  defdelegate(authorize(action, user, params), to: Palapa.Teams.Policy)

  def get!(id), do: Repo.get!(Team, id)

  def list(%Organization{} = organization) do
    query =
      from(
        t in Team,
        where: t.organization_id == ^organization.id,
        order_by: :name
      )

    Repo.all(query)
  end

  def list_users(%Team{} = team) do
    team
    |> Ecto.assoc(:users)
    |> order_by(:name)
    |> Repo.all()
  end

  def list_for_user(%Organization{} = organization, %User{} = user) do
    Ecto.assoc(organization, :teams)
    |> Bodyguard.scope(user)
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

  defp increment_counter_cache(changeset, struct, counter_name, value \\ 1) do
    prepare_changes(changeset, fn prepared_changeset ->
      prepared_changeset.repo.increment(struct, counter_name, value)
      prepared_changeset
    end)
  end
end
