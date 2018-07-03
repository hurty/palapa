defmodule PalapaWeb.EditorView do
  use PalapaWeb, :view

  def text_editor(organization) do
    render("editor.html", %{organization: organization})
  end
end
