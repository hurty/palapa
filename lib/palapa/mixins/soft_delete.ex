defmodule Palapa.SoftDelete do
  defmacro __using__(_opts) do
    quote do
      import Ecto.Query

      def soft_delete(resource) do
        resource
        |> Ecto.Changeset.change(%{deleted_at: DateTime.utc_now()})
        |> Palapa.Repo.update()
      end

      def reactivate(resource) do
        resource
        |> Ecto.Changeset.change(%{deleted_at: nil})
        |> Palapa.Repo.update()
      end

      def active?(resource) do
        is_nil(resource.deleted_at)
      end

      def soft_deleted?(resource) do
        !active?(resource)
      end

      def active(queryable) do
        from(q in queryable, where: is_nil(q.deleted_at))
      end
    end
  end
end
