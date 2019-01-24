defmodule PalapaWeb.Document.DocumentView do
  use PalapaWeb, :view

  def search_filters_applied?(conn) do
    conn.assigns.selected_team || !Palapa.Searches.blank_query?(conn.params["search"])
  end
end
