defmodule PalapaWeb.RichTextView do
  use PalapaWeb, :view

  alias Palapa.RichText.EmbeddedAttachment
  alias Palapa.Attachments

  defdelegate human_filesize(embedded_attachment), to: EmbeddedAttachment
  defdelegate image?(embedded_attachment), to: EmbeddedAttachment

  def secure_attachment_url(embedded_attachment, version \\ :original) do
    case Palapa.Access.verify_signed_id(embedded_attachment.sgid) do
      {:ok, id} ->
        Attachments.get!(id)
        |> Attachments.url(version)

      _ ->
        nil
    end
  end

  def text_editor(conn, organization, options \\ []) do
    toolbar_id = "editor_toolbar_#{Ecto.UUID.generate()}"

    render("editor.html", %{
      conn: conn,
      organization: organization,
      content_input_id: options[:content_input_id] || "content",
      data_target: options[:data_target] || "",
      placeholder: options[:placeholder],
      toolbar_id: toolbar_id
    })
  end
end
