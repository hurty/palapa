defmodule Palapa.RichText.RichTextView do
  use Phoenix.View, root: "lib/palapa/rich_text/conversion/templates", path: ""
  use Phoenix.HTML
  import Palapa.Gettext

  defdelegate image?(embedded_attachment), to: Palapa.Attachments

  def attachment_url(embedded_attachment, version \\ :original, content_disposition \\ "inline")

  def attachment_url(embedded_attachment, :auto, content_disposition) do
    version =
      if embedded_attachment.width < 800 do
        :original
      else
        :gallery
      end

    attachment_url(embedded_attachment, version, content_disposition)
  end

  def attachment_url(embedded_attachment, version, content_disposition) do
    url = embedded_attachment.url

    if url do
      "#{url}?version=#{version}&content-disposition=#{content_disposition}"
    else
      ""
    end
  end
end
