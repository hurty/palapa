defmodule PalapaWeb.AnnouncementView do
  use PalapaWeb, :view

  def excerpt(content) do
    first_words =
      content
      |> String.slice(0..380)
      |> strip_html_tags()

    if first_words != "" do
      first_words <> "..."
    end
  end

  def strip_html_tags(content) when is_nil(content), do: ""

  def strip_html_tags(content) do
    content
    |> String.replace(~r/<.*?>/, "")
    |> String.replace("&nbsp;", "")
  end

  def show_publication_options?(member) do
    member.role in [:owner, :admin]
  end
end
