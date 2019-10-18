defmodule Palapa.Context do
  defmacro __using__(_) do
    quote do
      alias Palapa.Accounts
      alias Palapa.Organizations
      alias Palapa.Organizations.Organization
      alias Palapa.Organizations.Member
      alias Palapa.Teams

      alias Palapa.Repo
      alias Palapa.Access

      alias Ecto.Multi
      import Ecto.Query
      import Ecto.Changeset
      import Palapa.Context
    end
  end

  def param(map, key) do
    convert_params(map)
    |> Map.get(Atom.to_string(key))
  end

  defp convert_params(params) do
    params
    |> Enum.reduce(nil, fn
      {key, _value}, nil when is_binary(key) ->
        nil

      {key, _value}, _ when is_binary(key) ->
        raise Ecto.CastError,
          type: :map,
          value: params,
          message:
            "expected params to be a map with atoms or string keys, " <>
              "got a map with mixed keys: #{inspect(params)}"

      {key, value}, nil when is_atom(key) ->
        [{Atom.to_string(key), value}]

      {key, value}, acc when is_atom(key) ->
        [{Atom.to_string(key), value} | acc]
    end)
    |> case do
      nil -> params
      list -> :maps.from_list(list)
    end
  end
end
