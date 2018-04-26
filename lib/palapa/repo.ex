defmodule Palapa.Repo do
  use Ecto.Repo, otp_app: :palapa
  use Scrivener, page_size: 100
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

  def count(queryable) do
    from(t in queryable, select: count(t.id))
    |> one()
  end

  @doc "Reload the given record"
  def reload(%module{id: id}) do
    get(module, id)
  end

  # Characters that have special meaning inside the `LIKE` clause of a query.
  #
  # `%` is a wildcard representing multiple characters.
  # `_` is a wildcard representing one character.
  # `\` is used to escape other metacharacters.
  @like_metacharacter_regex ~r/([\\%_])/

  # What to replace `LIKE` metacharacters with. We want to prepend a literal
  # backslash to each metacharacter. Because String#gsub does its own round of
  # interpolation on its second argument, we have to double escape backslashes
  # in this String.
  @like_escape "\\\\\1"
  def escape_like_pattern(value) do
    if value do
      String.replace(value, @like_metacharacter_regex, @like_escape)
    end
  end
end
