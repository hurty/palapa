defmodule Palapa.Searches.Search do
  use Palapa.Schema

  schema "searches" do
    belongs_to(:team, Palapa.Teams.Team)
    belongs_to(:member, Palapa.Organizations.Member)
    belongs_to(:page, Palapa.Documents.Page)
    belongs_to(:message, Palapa.Messages.Message)
  end
end
