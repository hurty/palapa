defmodule PalapaWeb.SearchController do
  use PalapaWeb, :controller

  alias Palapa.Searches

  plug(:put_navigation, "search")

  def index(conn, %{"query" => query}) do
    search_results = Searches.search(current_member(), query)

    if "XMLHttpRequest" in get_req_header(conn, "x-requested-with") do
      render(conn, "index_ajax.html", layout: false, search_results: search_results)
    else
      render(conn, "index.html", search_results: search_results)
    end
  end
end
