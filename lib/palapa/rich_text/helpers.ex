defmodule Palapa.RichText.Helpers do
  alias Palapa.RichText

  def rich_text(content)

  def rich_text(content) do
    RichText.to_html(content)
  end
end
