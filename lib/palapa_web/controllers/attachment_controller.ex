defmodule PalapaWeb.AttachmentController do
  use PalapaWeb, :controller

  alias Palapa.Attachments
  import PalapaWeb.Router.Helpers

  def create(conn, %{"file" => file}) do
    case Palapa.Attachments.create(current_organization(), file, current_member()) do
      {:ok, attachment} ->
        conn
        |> put_status(201)
        |> json(%{
          id: attachment.id,
          sgid: Palapa.Access.generate_signed_id(attachment.id),
          url: Palapa.Attachments.url(attachment),
          href: Palapa.Attachments.url(attachment)
        })

      {:error} ->
        conn
        |> put_status(400)
        |> json(%{})
    end
  end

  def original(conn, %{"id" => id}) do
    attachment = find_attachment(conn, id)
    redirect(conn, external: Attachments.url(attachment, :original))
  end

  def thumb(conn, %{"id" => id}) do
    attachment = find_attachment(conn, id)
    redirect(conn, external: Attachments.url(attachment, :thumb))
  end

  def download(conn, %{"id" => id}) do
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
