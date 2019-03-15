defmodule PalapaWeb.RichTextView do
  use PalapaWeb, :view

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
