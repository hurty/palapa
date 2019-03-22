defmodule Palapa.RichText.Helpers do
  alias Palapa.RichText

  def rich_text(content) do
    content
    |> RichText.to_formatted_html()
    |> Phoenix.HTML.raw()
  end
end
