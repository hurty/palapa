defmodule Palapa.Searches.Search do
  use Palapa.Schema

  @primary_key false
  schema "searches" do
    field(:resource_type, Palapa.Searches.SearchResourceTypeEnum)
    field(:updated_at, :utc_datetime)
    field(:rank, :float, virtual: true)
    belongs_to(:organization, Palapa.Organizations.Organization)
    belongs_to(:team, Palapa.Teams.Team)
    belongs_to(:message, Palapa.Messages.Message)
    belongs_to(:member, Palapa.Organizations.Member)
    belongs_to(:document, Palapa.Documents.Document)
    belongs_to(:page, Palapa.Documents.Page)
    belongs_to(:contact, Palapa.Contacts.Contact)
  end
end
