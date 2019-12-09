require Logger

defmodule Palapa.RichText.EmbeddedAttachment do
  @enforce_keys [:content_type]

  defstruct sgid: nil,
            attachment: nil,
            content_type: "application/octet-stream",
            url: nil,
            filename: nil,
            filesize: nil,
            width: nil,
            height: nil,
            custom_content: nil,
            presentation: nil,
            caption: nil

  def has_associated_attachment?(attachment) do
    attachment.sgid
  end

  def image?(attachment) do
    String.starts_with?(attachment.content_type, "image")
  end

  def remote_image?(attachment) do
    image?(attachment) && attachment.url && is_nil(attachment.sgid)
  end

  def custom?(attachment) do
    attachment.content_type =~ ~r/application\/vnd/
  end

  def resolve(embedded_attachment) do
    if(has_associated_attachment?(embedded_attachment)) do
      case Palapa.Access.verify_signed_id(embedded_attachment.sgid) do
        {:ok, id} ->
          attachment = Palapa.Attachments.get(id)

          if attachment do
            Map.put(embedded_attachment, :attachment, attachment)
          end

        _ ->
          Logger.warn(
            "Couldn't resolve attachment with sgid #{embedded_attachment.sgid}. Skipping."
          )
      end
    else
      embedded_attachment
    end
  end
end
