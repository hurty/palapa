defmodule PalapaWeb.SearchController do
  use PalapaWeb, :controller

  alias Palapa.Searches

  plug(:put_navigation, "search")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, params) do
    put_breadcrumb(conn, "Search", "#")
  end

  def index(conn, params) do
    if "XMLHttpRequest" in get_req_header(conn, "x-requested-with") do
      search_results = Searches.search(current_member(), params["query"], page_size: 5)
      render(conn, "index_ajax.html", layout: false, search_results: search_results)
    else
      search_results =
        Searches.search(current_member(), params["query"], page: params["page"], page_size: 15)

      render(conn, "index.html", search_results: search_results)
    end
  end
end
