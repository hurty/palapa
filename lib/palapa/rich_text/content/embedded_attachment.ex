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
