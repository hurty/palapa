defmodule Palapa.Factory do
  alias Palapa.Repo

  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Accounts.Account
  alias Palapa.Teams.{Team}

  alias Palapa.Messages.{Message}

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

  def insert_pied_piper! do
    # -- Organization
    pied_piper = insert!(:organization)

    # -- Members
    richard = insert!(:owner, organization: pied_piper)
    jared = insert!(:admin, organization: pied_piper)
    gilfoyle = insert!(:member, organization: pied_piper)

    # -- Teams
    tech_team =
      insert!(:team, organization: pied_piper, name: "Tech", members: [richard, gilfoyle])

    management_team =
      insert!(:team, organization: pied_piper, name: "Management", members: [richard, jared])

    %{
      organization: pied_piper,
      richard: richard,
      jared: jared,
      gilfoyle: gilfoyle,
      tech_team: tech_team,
      management_team: management_team
    }
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
      name: "Bertram Gilfoyle",
      role: :member,
      title: "Nerd"
    }
  end

  def build(:owner) do
    %Member{
      organization: build(:organization),
      account: build(:richard),
      name: "Richard Hendricks",
      role: :owner,
      title: "CEO"
    }
  end

  def build(:admin) do
    %Member{
      organization: build(:organization),
      account: build(:jared),
      name: "Jared Dunn",
      role: :admin,
      title: "Head of Business Development"
    }
  end

  def build(:richard) do
    %Account{
      email: "richard.hendricks@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:jared) do
    %Account{
      email: "jared.dunn@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:gilfoyle) do
    %Account{
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

  def build(:message) do
    %Message{
      organization: build(:organization),
      creator: build(:owner),
      published_to_everyone: true,
      title: "I have a great announcement to make",
      content: "<p>This is so great</p>"
    }
  end
end
