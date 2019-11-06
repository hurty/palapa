defmodule Palapa.RichText.Changeset do
  import Ecto.Changeset

  def put_rich_text_attachments(
        changeset,
        rich_text_field,
        attachments_assoc_name,
        attachable_type
      ) do
    content = get_field(changeset, rich_text_field)

    if content && content.attachments do
      attachments =
        content.attachments
        |> Enum.map(fn attachment -> Map.put(attachment, :attachable_type, attachable_type) end)

      put_assoc(changeset, attachments_assoc_name, attachments)
    else
      changeset
    end
  end
end
