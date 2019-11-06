defmodule Palapa.RichText.RichTextView do
  use Phoenix.View, root: "lib/palapa/rich_text/conversion/templates", path: ""
  use Phoenix.HTML

  alias Palapa.RichText.EmbeddedAttachment
  alias Palapa.Attachments

  defdelegate human_filesize(embedded_attachment), to: EmbeddedAttachment
  defdelegate image?(embedded_attachment), to: EmbeddedAttachment

  def secure_attachment_url(%EmbeddedAttachment{} = embedded_attachment, version) do
    id = embedded_attachment.attachment_id

    if id do
      Attachments.get!(id)
      |> Attachments.url(version)
    else
      ""
    end
  end
end
