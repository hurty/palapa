defmodule Palapa.Position do
  import Ecto.Query
  import Ecto.Changeset

  def recompute_positions(changeset) do
    old_position = changeset |> Map.get(:data) |> Map.get(:position)
    new_position = get_change(changeset, :position) || old_position
    old_section_id = changeset |> Map.get(:data) |> Map.get(:section_id)
    new_section_id = get_change(changeset, :section_id) || old_section_id

    changeset =
      if new_section_id != old_section_id do
        changeset
        |> reorder_after_deletion(:section_id, old_section_id, old_position)
      else
        changeset
      end

    changeset
    |> insert(:section_id, new_section_id, old_position, new_position)
  end

  def move_to_bottom(changeset, scope_field) do
    prepare_changes(changeset, fn cs ->
      scope_value = get_field(cs, scope_field)

      bottom_position =
        cs.data.__struct__
        |> where([s], field(s, ^scope_field) == ^scope_value)
        |> select([q], max(q.position))
        |> cs.repo.one!

      if bottom_position do
        put_change(cs, :position, bottom_position + 1)
      else
        put_change(cs, :position, 0)
      end
    end)
  end

  defp insert(changeset, scope_field, scope_value, old_position, new_position) do
    changeset
    |> prepare_changes(fn cs ->
      queryable = cs.data.__struct__

      queryable
      |> where([q], field(q, ^scope_field) == ^scope_value)
      |> where([s], s.position >= ^old_position)
      |> cs.repo.update_all(inc: [position: -1])

      queryable
      |> where([q], field(q, ^scope_field) == ^scope_value)
      |> where([s], s.position >= ^new_position)
      |> cs.repo.update_all(inc: [position: 1])

      cs
      |> force_change(:position, new_position)
    end)
  end

  defp reorder_after_deletion(changeset, scope_field, scope_value, old_position) do
    prepare_changes(changeset, fn cs ->
      cs.data.__struct__
      |> where([q], field(q, ^scope_field) == ^scope_value)
      |> where([q], q.position >= ^old_position)
      |> cs.repo.update_all(inc: [position: -1])

      cs
    end)
  end
end
