defmodule Palapa.AccountsTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Users
  alias Palapa.Users.User

  test "get!/2 returns the user with given id within the given organization" do
    organization = insert!(:organization)
    user = insert!(:member)
    insert!(:membership, organization: organization, user: user, role: :owner)
    fetched_user = Users.get!(user.id, organization)
    assert fetched_user.email == user.email
  end

  test "get_by/1 returns the user with the given email address" do
    user = insert!(:member)
    fetched_user = %User{} = Users.get_by(email: "bertram.gilfoyle@piedpiper.com")
    assert fetched_user.id == user.id
  end

  test "create/1 with valid data creates a user" do
    assert {:ok, %User{} = user} =
             Users.create(%{
               name: "Gavin Belson",
               email: "gavin.belson@hooli.com",
               password: "password"
             })

    assert user.name == "Gavin Belson"
    assert user.email == "gavin.belson@hooli.com"
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Users.create(%{name: "Gavin Belson", email: ""})
  end

  test "update/2 with valid data updates the user" do
    user = insert!(:member)

    assert {:ok, %User{} = user} =
             Users.update(user, %{name: "Big Head", email: "big.head@hooli.com"})

    assert user.name == "Big Head"
    assert user.email == "big.head@hooli.com"
  end

  test "update/2 with invalid data returns error changeset" do
    user = insert!(:member)

    assert {:error, %Ecto.Changeset{}} = Users.update(user, %{name: "Big Head", email: ""})
  end

  test "delete/1 deletes the user" do
    user = insert!(:member)
    assert {:ok, %User{}} = Users.delete(user)
    assert_raise Ecto.NoResultsError, fn -> Repo.get!(User, user.id) end
  end

  test "change/1 returns a user changeset" do
    user = insert!(:member)
    assert %Ecto.Changeset{} = Users.change(user)
  end
end
