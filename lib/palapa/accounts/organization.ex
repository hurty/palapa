defmodule Palapa.Accounts.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  alias Palapa.Accounts.{Organization, Membership}


  schema "organizations" do
    field :name, :string
    timestamps()

    has_many :memberships, Membership
    has_many :users, through: [:memberships, :user]
  end

  @doc false
  def changeset(%Organization{} = organization, attrs) do
    organization
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
