defmodule PalapaWeb.Document.SectionController do
  use PalapaWeb, :controller

  alias Palapa.Documents

  def create(conn, %{"document_id" => document_id, "section" => section_params}) do
    document =
      Documents.documents_visible_to(current_member())
      |> Documents.get_document!(document_id)

    with :ok <- permit(Documents, :update_document, current_member(), document) do
      case Documents.create_section(document, current_member(), section_params) do
        {:ok, section} ->
          render(conn, "section.html", layout: false, section: section, document: document)

        _ ->
          send_resp(conn, 400, "")
      end
    end
  end

  def update(conn, %{"id" => id, "section" => section_params}) do
    section =
      Documents.sections_visible_to(current_member())
      |> Documents.get_section!(id)

    with :ok <- permit(Documents, :update_document, current_member(), section.document) do
      case Documents.update_section(section, section_params) do
        {:ok, _updated_section} -> send_resp(conn, :ok, "")
        {:error, _changeset} -> send_resp(conn, :bad_request, "")
      end
    end
  end

  def delete(conn, %{"id" => id, "current_page_id" => current_page_id}) do
    section =
      Documents.sections_visible_to(current_member())
      |> Documents.get_section!(id)

    current_page =
      Documents.pages_visible_to(current_member())
      |> Documents.get_page!(current_page_id)

    with :ok <- permit(Documents, :update_document, current_member(), section.document) do
      case Documents.delete_section(section) do
        {:ok, _} ->
          redirect_page_id =
            if current_page.section_id == section.id do
              section.document.main_page_id
            else
              current_page_id
            end

          conn
          |> put_flash(:success, "The section \"#{section.title}\" has been deleted")
          |> redirect(
            to:
              document_page_path(
                conn,
                :show,
                current_organization(),
                redirect_page_id
              )
          )

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "The section \"#{section.title}\" could not be deleted")
          |> redirect(
            to:
              document_page_path(
                conn,
                :show,
                current_organization(),
                current_page
              )
          )
      end
    end
  end
end
