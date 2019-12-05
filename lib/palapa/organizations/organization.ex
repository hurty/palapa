defmodule Palapa.Organizations.Organization do
  use Palapa.Schema

  import Ecto.Query, warn: false
  alias Palapa.Accounts.Account
  alias Palapa.Organizations.{Member}
  alias Palapa.Invitations
  alias Palapa.Teams
  alias Palapa.Events.Event
  alias Palapa.Billing.{Customer, Subscription}

  schema "organizations" do
    timestamps()

    field(:name, :string)
    field(:default_timezone, :string)
    field(:allow_trial, :boolean)
    field(:deleted_at, :utc_datetime)

    belongs_to(:creator_account, Account)
    belongs_to(:customer, Customer)
    has_one(:subscription, Subscription)
    has_many(:invoices, through: [:customer, :invoices])
    has_many(:members, Member)
    has_many(:invitations, Invitations.Invitation)
    has_many(:teams, Teams.Team)
    has_many(:events, Event)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :default_timezone, :allow_trial])
    |> validate_required([:name])
  end

  def billing_changeset(organization, attrs) do
    organization
    |> cast(attrs, [:customer_id])
  end
end
