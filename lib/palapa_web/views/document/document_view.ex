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

  def form_template(document) do
    case document.type do
      :attachment -> "form_type_attachment.html"
      :link -> "form_type_link.html"
      _ -> "form.html"
    end
  end

  def file_icon("application/pdf"), do: "fas fa-file-pdf"
  def file_icon("application/zip"), do: "fas fa-file-archive"
  def file_icon("application/vnd.ms-powerpoint"), do: "fas fa-file-powerpoint"

  def file_icon("application/vnd.openxmlformats-officedocument.presentationml.presentation"),
    do: "fas fa-file-powerpoint"

  def file_icon("application/vnd.ms-excel"), do: "fas fa-file-excel"

  def file_icon("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
    do: "fas fa-file-excel"

  def file_icon("application/msword"), do: "fas fa-file-word"

  def file_icon("application/vnd.openxmlformats-officedocument.wordprocessingml.document"),
    do: "fas fa-file-word"

  def file_icon(content_type) do
    cond do
      String.starts_with?(content_type, "audio") -> "fas fa-file-audio"
      String.starts_with?(content_type, "image") -> "fas fa-file-image"
      true -> "fas fa-file-download"
    end
  end
end
