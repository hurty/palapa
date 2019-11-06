defmodule Palapa.RichText.RichTextView do
  use Phoenix.View, root: "lib/palapa/rich_text/conversion/templates", path: ""
  use Phoenix.HTML

  alias Palapa.RichText.EmbeddedAttachment

  defdelegate human_filesize(embedded_attachment), to: EmbeddedAttachment
  defdelegate image?(embedded_attachment), to: EmbeddedAttachment

  def attachment_url(
        %EmbeddedAttachment{} = embedded_attachment,
        version \\ :original,
        content_disposition \\ "inline"
      ) do
    url = embedded_attachment.url

    if url do
      "#{url}?version=#{version}&content-disposition=#{content_disposition}"
    else
      ""
    end
  end
end
