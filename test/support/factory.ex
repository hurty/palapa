defmodule Palapa.Factory do
  alias Palapa.Repo
  alias Palapa.Accounts.{Organization, User, Membership, Team}

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

  #
  # Factories
  #

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
      title: "CEO",
      role: :owner,
      memberships: [%Membership{organization: build(:organization), role: :owner}]
    }
  end

  def build(:admin) do
    %User{
      name: "Jared Dunn",
      email: "jared.dunn@piedpiper.com",
      title: "Head of Business Development",
      role: :admin
    }
  end

  def build(:member) do
    %User{
      name: "Bertram Gilfoyle",
      email: "bertram.gilfoyle@piedpiper.com",
      title: "Nerd",
      role: :member
    }
  end

  def build(:random_member) do
    %User{
      name: "John Doe #{random_integer()}",
      email: "john.doe_#{random_integer()}@piedpiper.com",
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
end
