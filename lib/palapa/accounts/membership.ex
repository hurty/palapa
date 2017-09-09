defmodule Palapa.Accounts.Membership do
  use Ecto.Schema
  import Ecto.Changeset
  alias Palapa.Accounts.{Membership, User, Organization}


  schema "memberships" do
    belongs_to :organization, Organization
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Membership{} = membership, attrs) do
    membership
    |> cast(attrs, [:organization_id, :user_id])
    |> validate_required([])
  end
end
