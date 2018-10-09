defmodule Palapa.Position do
  import Ecto.Query
  import Ecto.Changeset
  alias Palapa.Repo

  def positioned(query) do
    query
    |> order_by(asc: :position)
  end

  def move_to_bottom(changeset) do
    prepare_changes(changeset, fn cs ->
      %schema{} = cs.data
      bottom_position = current_bottom_position(schema) + 1
      put_change(cs, :position, bottom_position)
    end)
  end

  def current_bottom_position(schema) do
    last =
      schema
      |> select([:position])
      |> order_by(desc: :position)
      |> limit(1)
      |> Repo.one()

    if last do
      Map.get(last, :position)
    else
      0
    end
  end
end
