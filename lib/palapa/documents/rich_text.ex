defmodule Palapa.Documents.RichText do
  use Palapa.Schema

  alias Palapa.Documents.Page

  schema "rich_texts" do
    field(:body, :string)
    timestamps()
    belongs_to(:page, Page)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:body])
    |> unique_constraint(:page, name: "rich_texts_page_id_index")
  end
end
