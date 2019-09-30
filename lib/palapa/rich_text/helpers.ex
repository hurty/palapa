defmodule Palapa.RichText.Helpers do
  alias Palapa.RichText
  alias Palapa.RichText.RichTextView

  def rich_text(content) do
    content
    |> RichText.to_formatted_html()
    |> Phoenix.HTML.raw()
  end

  def rich_text_editor(form, field, attachments_url, options \\ []) do
    trix_formatted_value =
      Phoenix.HTML.Form.input_value(form, field)
      |> Palapa.RichText.to_trix()

    RichTextView.render("editor.html", %{
      form: form,
      attachments_url: attachments_url,
      content_input_value: trix_formatted_value,
      content_input_id: "editor_content_#{Ecto.UUID.generate()}",
      editor_data_target: options[:editor_data_target] || "",
      content_data_target: options[:content_data_target] || "",
      placeholder: options[:placeholder],
      toolbar_id: "editor_toolbar_#{Ecto.UUID.generate()}"
    })
  end
end
