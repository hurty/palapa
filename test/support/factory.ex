defmodule Palapa.Factory do
  alias Palapa.Repo
  alias Palapa.Accounts.{Organization, User, Membership, Team, TeamUser}

  #
  # Convenience functions
  #

  def build(factory_name, attrs) do
    build(factory_name) |> struct(attrs)
  end

  def insert!(factory_name, attrs \\ []) do
    build(factory_name, attrs)
    |> Repo.insert!()
  end

  def random_integer do
    System.unique_integer([:positive])
  end

  @password_hash Comeonin.Bcrypt.hashpwsalt("password")

  #
  # Factories
  #

  def insert_all do
    # -- Organization
    pied_piper = insert!(:organization)

    # -- Users
    richard = insert!(:owner)
    insert!(:membership, organization: pied_piper, user: richard, role: :owner)

    jared = insert!(:admin)
    insert!(:membership, organization: pied_piper, user: jared, role: :admin)

    gilfoyle = insert!(:member)
    insert!(:membership, organization: pied_piper, user: gilfoyle, role: :member)

    # -- Teams
    tech_team = insert!(:team, organization: pied_piper)
    management_team = insert!(:team, organization: pied_piper, name: "Management")

    insert!(:team_user, team: tech_team, user: richard)
    insert!(:team_user, team: tech_team, user: gilfoyle)
    insert!(:team_user, team: management_team, user: jared)
  end

  def build(:organization) do
    %Organization{
      name: "Pied Piper"
    }
  end

  def build(:membership) do
    %Membership{
      organization: build(:organization),
      user: build(:member),
      role: :member
    }
  end

  def build(:owner) do
    %User{
      name: "Richard Hendricks",
      email: "richard.hendricks@piedpiper.com",
      password_hash: @password_hash,
      title: "CEO",
      role: :owner
    }
  end

  def build(:admin) do
    %User{
      name: "Jared Dunn",
      email: "jared.dunn@piedpiper.com",
      password_hash: @password_hash,
      title: "Head of Business Development",
      role: :admin
    }
  end

  def build(:member) do
    %User{
      name: "Bertram Gilfoyle",
      email: "bertram.gilfoyle@piedpiper.com",
      password_hash: @password_hash,
      title: "Nerd",
      role: :member
    }
  end

  def build(:random_member) do
    %User{
      name: "John Doe #{random_integer()}",
      email: "john.doe_#{random_integer()}@piedpiper.com",
      password_hash: @password_hash,
      title: "Random guy",
      role: :member
    }
  end

  def build(:team) do
    %Team{
      name: "Tech",
      organization: build(:organization)
    }
  end

  def build(:team_user) do
    %TeamUser{
      team: build(:organization),
      user: build(:member)
    }
  end
end
