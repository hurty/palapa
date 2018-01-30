defmodule Palapa.Repo do
  use Ecto.Repo, otp_app: :palapa
  import Ecto.Query

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  def increment(struct, field, value \\ 1) do
    primary_key = Ecto.primary_key(struct)

    struct.__struct__
    |> where(^primary_key)
    |> update_all([inc: [{field, value}]], returning: true)
    |> case do
      {1, updated_struct} -> {:ok, updated_struct}
      _ -> {:error, struct}
    end
  end

  def decrement(struct, field, value \\ -1) do
    increment(struct, field, value)
  end

  @doc "Returns true if at least one record exists for the given query, or false otherwise."
  def exists?(queryable) do
    from(x in queryable, select: 1, limit: 1)
    |> all()
    |> case do
      [1] -> true
      [] -> false
    end
  end
end
