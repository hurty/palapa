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
          url: Routes.attachment_url(conn, :show, current_organization(conn), attachment.id)
        })

      _ ->
        conn
        |> put_status(400)
        |> json(%{})
    end
  end

  @versions_whitelist ["original", "gallery"]
  def show(conn, params) do
    attachment = Attachments.get!(params["id"])

    version =
      if Enum.member?(@versions_whitelist, params["version"]) do
        String.to_atom(params["version"])
      else
        nil
      end

    with :ok <- permit(Attachments.Policy, :show, current_member(conn), attachment) do
      conn
      |> redirect(external: Attachments.url(attachment, version, params["content_disposition"]))
    end
  end
end
