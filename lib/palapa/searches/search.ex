defmodule Palapa.Searches.Search do
  use Palapa.Schema

  schema "searches" do
    field(:resource_type, Palapa.Searches.SearchResourceTypeEnum)
    field(:updated_at, :utc_datetime)
    belongs_to(:organization, Palapa.Organizations.Organization)
    belongs_to(:team, Palapa.Teams.Team)
    belongs_to(:message, Palapa.Messages.Message)
    belongs_to(:member, Palapa.Organizations.Member)
    belongs_to(:page, Palapa.Documents.Page)
  end
end
