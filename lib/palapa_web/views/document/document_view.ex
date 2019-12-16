defmodule PalapaWeb.Document.DocumentView do
  use PalapaWeb, :view

  def search_filters_applied?(conn) do
    conn.assigns.selected_team || !Palapa.Searches.blank_query?(conn.params["search"])
  end

  def flash_for_deleted_document(conn, document) do
    content_tag(:span) do
      [
        gettext("The document %{document_title} has been deleted. ", %{
          document_title: Helpers.truncate_string(document.title)
        }),
        link(gettext("Undo"),
          to:
            Routes.document_trash_path(conn, :delete, conn.assigns.current_organization, document),
          data: [controller: "link", action: "link#delete"],
          class: "text-green-800 hover:underline"
        )
      ]
    end
  end

  def document_type(document) do
    case document.type do
      :attachment -> gettext("Attachment")
      :link -> gettext("Link")
      _ -> gettext("Document")
    end
  end

  def document_type_icon(document) do
    case document.type do
      :attachment -> "fas fa-paperclip"
      :link -> "fas fa-link"
      _ -> "fas fa-file-alt"
    end
  end
end
