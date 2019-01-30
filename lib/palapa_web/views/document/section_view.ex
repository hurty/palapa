defmodule PalapaWeb.Document.SectionView do
  use PalapaWeb, :view

  def list_sections_for_select(document) do
    [head | tail] =
      Enum.map(document.sections, fn section -> [key: section.title, value: section.id] end)

    tail
    |> List.insert_at(0, Keyword.put(head, :key, "Document root"))
  end
end
