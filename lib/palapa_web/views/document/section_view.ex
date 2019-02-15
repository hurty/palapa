defmodule PalapaWeb.Document.SectionView do
  use PalapaWeb, :view

  def list_sections_for_select(document) do
    Enum.map(document.sections, fn section -> [key: section.title, value: section.id] end)
  end
end
