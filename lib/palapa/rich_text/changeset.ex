defmodule Palapa.RichText.Changeset do
  import Ecto.Changeset
  import Ecto.Query
  alias Palapa.Attachments.Attachment

  def put_rich_text_attachments(
        changeset,
        rich_text_field,
        attachments_assoc_name,
        attachable_type
      ) do
    content = get_field(changeset, rich_text_field)

    if content && content.attachments do
      changeset
      |> put_assoc(attachments_assoc_name, content.attachments)
      |> prepare_changes(fn changeset ->
        attachments_ids = content.attachments |> Enum.map(& &1.id)
        query = from a in Attachment, where: a.id in ^attachments_ids
        changeset.repo.update_all(query, set: [attachable_type: attachable_type])
        changeset
      end)
    else
      changeset
    end
  end
end
