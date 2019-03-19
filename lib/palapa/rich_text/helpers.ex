defmodule Palapa.RichText.Helpers do
  alias Palapa.RichText
  alias Palapa.RichText.Content

  def rich_text(content) when is_nil(content), do: nil

  def rich_text(content) when is_binary(content) do
    content
    # |> RichText.from_canonical()
    # TEMPORARY (fixtures are not yet canonical)
    |> RichText.from_trix()
    |> do_rich_text()
  end

  def rich_text(%Content{} = content) do
    do_rich_text(content)
  end

  defp do_rich_text(content) do
    content
    |> RichText.to_html()
    |> Phoenix.HTML.raw()
  end
end
