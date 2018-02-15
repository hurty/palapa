defmodule Palapa.Factory do
  alias Palapa.Repo
  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Accounts.Account
  alias Palapa.Teams.{Team}

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
    richard = insert!(:owner, organization: pied_piper)
    jared = insert!(:admin, organization: pied_piper)
    gilfoyle = insert!(:member, organization: pied_piper)

    # -- Teams
    insert!(:team, organization: pied_piper, members: [richard, gilfoyle])
    insert!(:team, organization: pied_piper, name: "Management", members: [richard, jared])
  end

  def build(:organization) do
    %Organization{
      name: "Pied Piper"
    }
  end

  def build(:member) do
    %Member{
      organization: build(:organization),
      account: build(:gilfoyle),
      role: :member,
      title: "Nerd"
    }
  end

  def build(:owner) do
    %Member{
      organization: build(:organization),
      account: build(:richard),
      role: :owner,
      title: "CEO"
    }
  end

  def build(:admin) do
    %Member{
      organization: build(:organization),
      account: build(:jared),
      role: :admin,
      title: "Head of Business Development"
    }
  end

  def build(:richard) do
    %Account{
      name: "Richard Hendricks",
      email: "richard.hendricks@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:jared) do
    %Account{
      name: "Jared Dunn",
      email: "jared.dunn@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:gilfoyle) do
    %Account{
      name: "Bertram Gilfoyle",
      email: "bertram.gilfoyle@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:team) do
    %Team{
      organization: build(:organization),
      name: "Tech"
    }
  end
end
