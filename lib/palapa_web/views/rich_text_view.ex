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

  def text_editor(form, field, conn, options \\ []) do
    organization = conn.assigns.current_organization

    trix_formatted_value =
      Phoenix.HTML.Form.input_value(form, field)
      |> Palapa.RichText.to_trix()

    render("editor.html", %{
      form: form,
      attachments_url: attachment_url(conn, :create, organization),
      organization: organization,
      content_input_value: trix_formatted_value,
      content_input_id: "editor_content_#{Ecto.UUID.generate()}",
      editor_data_target: options[:editor_data_target] || "",
      content_data_target: options[:content_data_target] || "",
      placeholder: options[:placeholder],
      toolbar_id: "editor_toolbar_#{Ecto.UUID.generate()}"
    })
  end
end
