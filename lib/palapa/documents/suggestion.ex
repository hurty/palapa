defmodule Palapa.Documents.Suggestion do
  use Palapa.Schema
  alias Palapa.Documents.{Page}
  alias Palapa.Organizations.{Member}

  schema "document_suggestions" do
    field(:content, :string)
    timestamps()

    belongs_to(:page, Page)
    has_one(:document, through: [:page, :document])
    belongs_to(:author, Member)
    belongs_to(:parent_suggestion, __MODULE__)
    has_many(:replies, __MODULE__, foreign_key: :parent_suggestion_id)

    field(:closed_at, :utc_datetime)
    belongs_to(:closure_author, Member)
  end

  def changeset(suggestion, attrs) do
    suggestion
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
