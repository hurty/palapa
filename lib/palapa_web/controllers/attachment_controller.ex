defmodule PalapaWeb.AttachmentController do
  use PalapaWeb, :controller

  alias Palapa.Attachments

  def create(conn, %{"file" => file}) do
    case Palapa.Attachments.create(current_organization(conn), file, current_member(conn)) do
      {:ok, attachment} ->
        sgid = Palapa.Access.generate_signed_id(attachment.id)

        conn
        |> put_status(201)
        |> json(%{
          sgid: sgid,
          url:
            Routes.attachment_url(conn, :show, current_organization(conn), attachment.id,
              version: "gallery"
            )
        })

      _ ->
        conn
        |> put_status(400)
        |> json(%{})
    end
  end

  def show(conn, params) do
    attachment = Attachments.get!(params["id"])

    with :ok <- permit(Attachments.Policy, :show, current_member(conn), attachment) do
      opts =
        params
        |> Map.take(["version", "content-disposition"])

      redirect(conn, external: Attachments.url(attachment, opts))
    end
  end
end
