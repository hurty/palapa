defmodule PalapaWeb.SearchView do
  use PalapaWeb, :view

  def resource_path(conn, search_result) do
    organization = conn.assigns.current_organization

    case search_result.resource_type do
      :team ->
        member_path(conn, :index, organization, team_id: search_result.resource_id)

      :member ->
        member_path(conn, :show, organization, search_result.resource_id)

      :message ->
        message_path(conn, :show, organization, search_result.resource_id)

      :page ->
        document_page_path(conn, :show, organization, search_result.resource_id)
    end
  end

  def search_result_template_path(search_result) do
    case search_result.resource_type do
      :team ->
        "search_result_team.html"

      :member ->
        "search_result_member.html"

      :message ->
        "search_result_message.html"

      :page ->
        "search_result_page.html"
    end
  end

  def formatted_resource_type(search_result) do
    case search_result.resource_type do
      :team ->
        "Team"

      :member ->
        "Member"

      :message ->
        "Message"

      :page ->
        "Document page"
    end
  end
end
