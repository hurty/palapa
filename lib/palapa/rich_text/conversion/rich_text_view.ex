defmodule Palapa.RichText.RichTextView do
  use Phoenix.View, root: "lib/palapa/rich_text/conversion/templates", path: ""
  use Phoenix.HTML

  alias Palapa.RichText.EmbeddedAttachment
  alias Palapa.Attachments

  defdelegate human_filesize(embedded_attachment), to: EmbeddedAttachment
  defdelegate image?(embedded_attachment), to: EmbeddedAttachment

  def secure_attachment_url(embedded_attachment, version \\ :original) do
    case Palapa.Access.verify_signed_id(embedded_attachment.sgid) do
      {:ok, id} ->
        Attachments.get!(id)
        |> Attachments.url(version)

      _ ->
        nil
    end
  end
end
