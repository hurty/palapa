defmodule Palapa.RegistrationsTest do
  use Palapa.DataCase
  alias Palapa.Accounts.Registrations
  alias Palapa.Accounts.Registration
  import Palapa.Factory

  test "create/1 with valid data creates an account, a organization and a member" do
    assert {:ok,
            %{
              account: account,
              organization_membership: %{organization: organization, member: member, event: event}
            }} =
             Registrations.create(
               %{
                 email: "richard.hendricks@piedpiper.com",
                 name: "Richard Hendricks",
                 password: "password",
                 organization_name: "Pied Piper"
               },
               "en"
             )

    assert account.email == "richard.hendricks@piedpiper.com"
    assert account.name == "Richard Hendricks"
    assert account.password_hash
    assert organization.name == "Pied Piper"
    assert member.role == :owner
    assert event.action == :new_organization
  end

  test "create/1 with invalid data returns an error and a changeset" do
    assert {:error, :registration, %Ecto.Changeset{}, _} =
             Registrations.create(
               %{
                 email: ""
               },
               "en"
             )
  end

  test "create/1 with an email already used returns an error" do
    insert!(:owner)

    assert {:error, :account, %Ecto.Changeset{}, _} =
             Registrations.create(
               %{
                 email: "richard.hendricks@piedpiper.com",
                 name: "Richard Hendricks",
                 password: "password",
                 organization_name: "Pied Piper"
               },
               "en"
             )
  end

  test "create/1 with a password too short returns an error" do
    assert {:error, :registration, %Ecto.Changeset{}, _} =
             Registrations.create(
               %{
                 email: "richard.hendricks@piedpiper.com",
                 name: "Richard Hendricks",
                 password: "short",
                 organization_name: "Pied Piper"
               },
               "en"
             )
  end

  test "change/1 returns the changeset" do
    assert %Ecto.Changeset{} = Registrations.change(%Registration{})
  end
end
