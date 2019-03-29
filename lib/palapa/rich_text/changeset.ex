defmodule Palapa.RichText.Changeset do
  import Ecto.Changeset

  def put_rich_text_attachments(changeset, rich_text_field, attachments_assoc) do
    content = get_field(changeset, rich_text_field)

    if content do
      Ecto.Changeset.put_assoc(changeset, attachments_assoc, content.attachments)
    else
      changeset
    end
  end
end
