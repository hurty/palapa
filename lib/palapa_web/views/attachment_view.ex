defmodule PalapaWeb.AttachmentView do
  use PalapaWeb, :view

  def url(attachment, version \\ nil) do
    Palapa.Attachments.url(attachment, version)
  end
end
