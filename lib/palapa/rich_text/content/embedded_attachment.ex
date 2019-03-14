defmodule Palapa.RichText.EmbeddedAttachment do
  defstruct ~w(
    sgid
    id
    missing

    content_type
    url
    href
    filename
    filesize
    width
    height
    previewable

    presentation
    caption
  )a
end
