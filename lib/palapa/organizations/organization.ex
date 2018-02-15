defmodule Palapa.Organizations.Organization do
  use Palapa.Schema

  import Ecto.Query, warn: false
  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Teams.Team

  schema "organizations" do
    field(:name, :string)
    timestamps()

    has_many(:members, Member)
    has_many(:teams, Team)
  end

  @doc false
  def changeset(%Organization{} = organization, attrs) do
    organization
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
