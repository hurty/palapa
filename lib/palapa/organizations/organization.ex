defmodule Palapa.Organizations.Organization do
  use Palapa.Schema

  import Ecto.Query, warn: false
  alias Palapa.Organizations.{Member}
  alias Palapa.Invitations
  alias Palapa.Teams
  alias Palapa.Events.Event
  alias Palapa.Billing.Customer

  schema "organizations" do
    field(:name, :string)
    field(:default_timezone, :string)
    field(:valid_until, :utc_datetime)
    timestamps()

    belongs_to(:customer, Customer)
    has_many(:members, Member)
    has_many(:invitations, Invitations.Invitation)
    has_many(:teams, Teams.Team)
    has_many(:events, Event)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :default_timezone])
    |> validate_required([:name])
  end

  def billing_changeset(organization, attrs) do
    organization
    |> cast(attrs, [:customer_id, :valid_until])
  end
end
