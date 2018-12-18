defmodule Palapa.Searches.SearchResult do
  use Palapa.Schema

  alias Palapa.Searches.{SearchResourceTypeEnum}

  schema "search result" do
    field(:resource_type, SearchResourceTypeEnum)
    field(:resource_id, Ecto.UUID)
    field(:title, :string)
    field(:updated_at, :utc_datetime)
  end
end
