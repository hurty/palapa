defmodule Palapa.Documents.Suggestion do
  use Palapa.Schema
  alias Palapa.Documents.{Page, SuggestionComment}
  alias Palapa.Organizations.{Member}

  schema "document_suggestions" do
    field(:content, :string)
    timestamps()

    belongs_to(:page, Page)
    has_one(:document, through: [:page, :document])
    belongs_to(:author, Member)
    has_many(:suggestion_comments, SuggestionComment)

    field(:closed_at, :utc_datetime)
    belongs_to(:closure_author, Member)
  end

  def changeset(suggestion, attrs) do
    suggestion
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
