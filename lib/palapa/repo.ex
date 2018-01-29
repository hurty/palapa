defmodule Palapa.Repo do
  use Ecto.Repo, otp_app: :palapa
  require Ecto.Query

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  def increment(struct, field, value \\ 1) do
    primary_key = Ecto.primary_key(struct)

    result =
      struct.__struct__
      |> Ecto.Query.where(^primary_key)
      |> update_all(inc: [{field, value}])

    case result do
      {1, _} -> {:ok, struct}
      _ -> {:error, struct}
    end
  end

  def decrement(struct, field, value \\ -1) do
    increment(struct, field, value)
  end
end
