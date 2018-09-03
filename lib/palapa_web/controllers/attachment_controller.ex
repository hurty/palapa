defmodule PalapaWeb.AttachmentController do
  use PalapaWeb, :controller

  alias Palapa.Attachments

  def create(conn, %{"file" => file}) do
    case Palapa.Attachments.create(current_organization(), file) do
      {:ok, attachment} ->
        conn
        |> put_status(201)
        |> json(%{
          attachment_sid: Palapa.Access.generate_signed_id(attachment.id),
          original_url:
            PalapaWeb.Router.Helpers.attachment_attachment_path(
              conn,
              :original,
              current_organization(),
              attachment.id,
              attachment.filename
            ),
          thumb_url:
            PalapaWeb.Router.Helpers.attachment_attachment_path(
              conn,
              :thumb,
              current_organization(),
              attachment.id,
              attachment.filename
            ),
          download_url:
            PalapaWeb.Router.Helpers.attachment_attachment_path(
              conn,
              :download,
              current_organization(),
              attachment.id,
              attachment.filename
            )
        })

      {:error} ->
        conn
        |> put_status(400)
        |> json(%{})
    end
  end

  def original(conn, %{"attachment_id" => id}) do
    attachment = find_attachment(conn, id)
    redirect(conn, to: Attachments.url(attachment, :original))
  end

  def thumb(conn, %{"attachment_id" => id}) do
    attachment = find_attachment(conn, id)
    redirect(conn, to: Attachments.url(attachment, :original))
  end

  def download(conn, %{"attachment_id" => id}) do
    attachment = find_attachment(conn, id)
    redirect(conn, to: Attachments.url(attachment, :original))
  end

  defp find_attachment(conn, id) do
    Attachments.visible_to(current_member())
    |> Attachments.get!(id)
  end
end
