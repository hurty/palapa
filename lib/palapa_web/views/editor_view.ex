defmodule PalapaWeb.EditorView do
  use PalapaWeb, :view

  def text_editor(conn, organization) do
    render("editor.html", %{conn: conn, organization: organization})
  end
end
