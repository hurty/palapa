defmodule PalapaWeb.SearchView do
  use PalapaWeb, :view

  def search_result_template_path(search_result) do
    case search_result.resource_type do
      :team ->
        "search_result_team.html"

      :member ->
        "search_result_member.html"

      :message ->
        "search_result_message.html"

      :document ->
        "search_result_document.html"

      :page ->
        "search_result_page.html"
    end
  end
end
