defmodule PalapaWeb.AttachmentController do
  use PalapaWeb, :controller

  def create(conn, %{"file" => file}) do
    case Palapa.Attachments.create(current_organization(), file) do
      {:ok, attachment} ->
        conn
        |> put_status(201)
        |> json(%{
          attachment_uuid: attachment.id,
          original_url: Palapa.Attachments.url(attachment, :original),
          thumb_url: Palapa.Attachments.url(attachment, :thumb)
        })

      {:error} ->
        conn
        |> put_status(400)
        |> json(%{})
    end
  end
end
