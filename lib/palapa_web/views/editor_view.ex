defmodule PalapaWeb.EditorView do
  use PalapaWeb, :view

  def text_editor(conn, organization, options \\ []) do
    render("editor.html", %{
      conn: conn,
      organization: organization,
      content_input_id: options[:content_input_id] || "content",
      data_target: options[:data_target] || "",
      placeholder: options[:placeholder]
    })
  end
end
