defmodule Palapa.Organizations.Member do
  use Palapa.Schema
  use Arc.Ecto.Schema

  alias Palapa.Accounts.Account
  alias Palapa.Organizations.{Member, Organization, RoleEnum}
  alias Palapa.Invitations
  alias Palapa.Teams.{Team, TeamMember}

  schema "members" do
    belongs_to(:organization, Organization)
    belongs_to(:account, Account)
    field(:name, :string)
    field(:role, RoleEnum, default: :member)
    field(:title, :string)
    field(:avatar, Palapa.Avatar.Type)
    timestamps()

    has_many(:invitations, Invitations.Invitation, foreign_key: :creator_id)
    many_to_many(:teams, Team, join_through: TeamMember, on_replace: :delete)
  end

  def changeset(%Member{} = member, attrs) do
    member
    |> cast(attrs, [:organization_id, :account_id, :name, :role, :title])
    |> validate_required([:organization_id, :account_id, :name])
    |> unique_constraint(:organization_id, name: "members_organization_id_account_id_index")
  end

  def update_profile_changeset(%Member{} = member, attrs) do
    member
    |> cast(attrs, [:name, :role, :title])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:name])
  end
end
