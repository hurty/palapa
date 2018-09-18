defmodule PalapaWeb.AttachmentController do
  use PalapaWeb, :controller

  alias Palapa.Attachments
  import PalapaWeb.Router.Helpers

  def create(conn, %{"file" => file}) do
    case Palapa.Attachments.create(current_organization(), file) do
      {:ok, attachment} ->
        conn
        |> put_status(201)
        |> json(%{
          attachment_sid: Palapa.Access.generate_signed_id(attachment.id),
          original_url:
            attachment_attachment_url(
              conn,
              :original,
              current_organization(),
              attachment.id,
              attachment.filename
            ),
          thumb_url:
            attachment_attachment_url(
              conn,
              :thumb,
              current_organization(),
              attachment.id,
              attachment.filename
            ),
          download_url:
            attachment_attachment_url(
              conn,
              :download,
              current_organization(),
              attachment.id,
              attachment.filename
            ),
          delete_url: attachment_url(conn, :delete, current_organization(), attachment)
        })

      {:error} ->
        conn
        |> put_status(400)
        |> json(%{})
    end
  end

  def original(conn, %{"attachment_id" => id}) do
    attachment = find_attachment(conn, id)
    redirect(conn, external: Attachments.url(attachment, :original))
  end

  def thumb(conn, %{"attachment_id" => id}) do
    attachment = find_attachment(conn, id)
    redirect(conn, external: Attachments.url(attachment, :thumb))
  end

  def download(conn, %{"attachment_id" => id}) do
    attachment = find_attachment(conn, id)
    redirect(conn, external: Attachments.url(attachment, :original))
  end

  def delete(conn, %{"id" => id}) do
    attachment = find_attachment(conn, id)

    with :ok <- permit(Attachments, :delete, current_member(), attachment) do
      Attachments.delete!(attachment)

      conn
      |> send_resp(:no_content, "")
    end
  end

  defp find_attachment(conn, id) do
    Attachments.visible_to(current_member())
    |> Attachments.get!(id)
  end
end
