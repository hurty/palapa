defmodule Palapa.Documents.SuggestionComment do
  use Palapa.Schema
  alias Palapa.Documents.{Suggestion}
  alias Palapa.Organizations.{Member}

  schema "document_suggestion_comments" do
    field(:content, :string)
    timestamps()

    belongs_to(:suggestion, Suggestion)
    belongs_to(:author, Member)
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
