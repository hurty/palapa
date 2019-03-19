defmodule Palapa.RichText.EmbeddedAttachment do
  defstruct ~w(
    sgid
    attachment_id
    content_type
    url
    filename
    filesize
    width
    height
    custom_content
    previewable
    presentation
    caption
  )a

  def has_associated_attachment?(attachment) do
    attachment.attachment_id
  end

  def image?(attachment) do
    attachment.content_type =~ ~r/^image(\/.+|$)/
  end

  def remote_image?(attachment) do
    image?(attachment) && attachment.url && is_nil(attachment.sgid)
  end

  def custom?(attachment) do
    attachment.content_type =~ ~r/application\/vnd/
  end

  @sizes ["Bytes", "KB", "MB", "GB", "TB", "PB"]

  def human_filesize(%__MODULE__{} = attachment) do
    case attachment.filesize do
      nil ->
        nil

      "0" ->
        "0 Byte"

      "1" ->
        "1 Byte"

      _ ->
        try do
          number = String.to_integer(attachment.filesize)

          exp =
            (:math.log(number) / :math.log(1024))
            |> Float.floor()
            |> round

          humanSize =
            (number / :math.pow(1024, exp))
            |> Float.ceil(2)

          "#{humanSize} #{Enum.at(@sizes, exp)}"
        rescue
          _ -> "Size unknown"
        end
    end
  end
end
