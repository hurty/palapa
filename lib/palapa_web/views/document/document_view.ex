defmodule PalapaWeb.Document.DocumentView do
  use PalapaWeb, :view

  def search_filters_applied?(conn) do
    conn.assigns.selected_team || !Palapa.Searches.blank_query?(conn.params["search"])
  end

  def flash_for_deleted_document(conn, document) do
    content_tag(:span) do
      [
        "The document '#{truncate_string(document.title)}' has been deleted. ",
        link("Undo",
          to: document_trash_path(conn, :delete, conn.assigns.current_organization, document),
          method: :delete,
          class: "text-green-darker hover:underline"
        )
      ]
    end
  end
end
