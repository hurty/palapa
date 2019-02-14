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

  def delete(conn, %{"id" => id}) do
    section =
      Documents.sections_visible_to(current_member())
      |> Documents.get_section!(id)

    with :ok <- permit(Documents, :update_document, current_member(), section.document) do
      case Documents.delete_section(section) do
        {:ok, _} ->
          send_resp(conn, :ok, "")

        {:error, _changeset} ->
          send_resp(conn, :bad_request, "")
      end
    end
  end
end
