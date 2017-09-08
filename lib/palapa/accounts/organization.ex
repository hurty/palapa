defmodule Palapa.Accounts.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  alias Palapa.Accounts.Organization


  schema "organizations" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%Organization{} = organization, attrs) do
    organization
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
