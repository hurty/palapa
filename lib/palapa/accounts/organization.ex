defmodule Palapa.Accounts.Organization do
  use Palapa.Schema

  import Ecto.Query
  alias Palapa.Accounts.{Organization, User, Membership}
  alias Palapa.Teams.Team
  @behaviour Bodyguard.Schema

  schema "organizations" do
    field(:name, :string)
    timestamps()

    has_many(:memberships, Membership)
    has_many(:users, through: [:memberships, :user])
    has_many(:teams, Team)
  end

  @doc false
  def changeset(%Organization{} = organization, attrs) do
    organization
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def scope(query, %User{} = user, _) do
    from(
      t in query,
      join: m in Membership,
      on: [organization_id: t.id],
      where: m.user_id == ^user.id
    )
  end
end
