defmodule Palapa.Organizations.Member do
  use Palapa.Schema

  alias Palapa.Accounts.Account
  alias Palapa.Organizations.{Member, Organization, PersonalInformation, RoleEnum}
  alias Palapa.Invitations
  alias Palapa.Teams.{Team, TeamMember}

  schema "members" do
    belongs_to(:organization, Organization)
    belongs_to(:account, Account)
    field(:role, RoleEnum, default: :member)
    field(:title, :string)
    field(:deleted_at, :utc_datetime)
    timestamps()

    has_many(:invitations, Invitations.Invitation, foreign_key: :creator_id)
    many_to_many(:teams, Team, join_through: TeamMember, on_replace: :delete)
    has_many(:personal_informations, PersonalInformation)
  end

  def create_changeset(%Member{} = member, attrs \\ %{}) do
    member
    |> cast(attrs, [:organization_id, :account_id, :role, :title])
    |> validate_required([:organization_id, :account_id])
    |> unique_constraint(:organization_id, name: "members_organization_id_account_id_index")
  end

  def update_profile_changeset(%Member{} = member, attrs \\ %{}) do
    member
    |> cast(attrs, [:title])
    |> nilify_if_blank(:title)
  end

  defp nilify_if_blank(changeset, attribute) do
    new_value = get_change(changeset, attribute)

    if new_value && blank?(new_value) do
      force_change(changeset, attribute, nil)
    else
      changeset
    end
  end

  defp blank?(value) when is_nil(value) do
    true
  end

  defp blank?(value) when is_binary(value) do
    String.length(String.trim(value)) == 0
  end
end
