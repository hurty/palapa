defmodule PalapaWeb.Document.PageView do
  use PalapaWeb, :view

  alias Palapa.Documents

  def page_title(page) do
    if Documents.main_page?(page), do: "Home", else: page.title
  end
end
