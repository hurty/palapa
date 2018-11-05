defmodule Palapa.Documents.Section do
  use Palapa.Schema
  alias Palapa.Documents.{Document, Page, Section}
  alias Palapa.Organizations

  import Ecto.Query

  schema "sections" do
    field(:title, :string)
    field(:position, :integer)
    timestamps()

    belongs_to(:document, Document)
    belongs_to(:last_author, Organizations.Member)
    has_many(:pages, Page)
  end

  def changeset(section, attrs) do
    section
    |> cast(attrs, [:title, :position])
    |> set_position
    |> validate_required([:title])
  end

  defp set_position(changeset) do
    new_position = get_change(changeset, :position)
    document_id = get_field(changeset, :document_id)
    old_position = changeset.data.position

    if new_position && new_position != old_position do
      base_query =
        from(s in Section,
          where: s.document_id == ^document_id
        )

      update_position(changeset, base_query, old_position, new_position)
    else
      changeset
    end
  end

  defp update_position(changeset, base_query, old_position, new_position) do
    changeset
    |> prepare_changes(fn cs ->
      base_query
      |> where([s], s.position >= ^old_position)
      |> cs.repo.update_all(inc: [position: -1])

      base_query
      |> where([s], s.position >= ^new_position)
      |> cs.repo.update_all(inc: [position: 1])

      cs
      |> force_change(:position, new_position)
    end)
  end
end

# INSERT
# Inserting a comment requires making room for it and insert, like:
#
# begin;
# # n is the new comment index, must be 0 <= n <= count(comments)
# update comments set position = position + 1 where position >= n;
# insert into comments ...;
# commit;

# DELETE
# Deleting a comment requires to fill the gap it creates:
#
# begin;
# delete from comments where id = ...;
# # n is the comment index
# update comments set position = position - 1 where position >= n;
# commit;

# UPDATE
# Updating (reordering) a comment requires more renumbering operations:
# begin;
# # n is the old index
# update comments set position = position - 1 where position >= n;
# # if the post_id change, do the following operations on the new post_id
# # m is the new index
# update comments set position = position + 1 where position >= m;
# update comments set position = m where id = theid;
# commit;
