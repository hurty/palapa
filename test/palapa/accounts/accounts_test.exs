defmodule Palapa.AccountsTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Accounts
  alias Palapa.Accounts.Account

  test "get!/1 returns the account with given id" do
    richard = insert!(:richard)
    account = Accounts.get!(richard.id)
    assert account.id == richard.id
  end

  test "get_by/1 returns the account with the given email address" do
    richard = insert!(:richard)
    account = %Account{} = Accounts.get_by(email: "richard.hendricks@piedpiper.com")
    assert account.id == richard.id
  end

  test "create/1 with valid data creates a account" do
    assert {:ok, %Account{}} =
             Accounts.create(%{
               name: "Gavin Belson",
               email: "gavin.belson@hooli.com",
               password: "password"
             })
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create(%{email: ""})
  end

  test "update/2 with valid data updates the account" do
    richard = insert!(:richard)

    assert {:ok, %{account: account}} =
             Accounts.update_account(richard, %{email: "big.head@hooli.com"})

    assert account.email == "big.head@hooli.com"
  end

  test "update/2 with invalid data returns error changeset" do
    richard = insert!(:richard)

    assert {:error, :account, %Ecto.Changeset{}, _changes} =
             Accounts.update_account(richard, %{email: ""})
  end

  test "delete/1 deletes the account" do
    richard = insert!(:richard)
    assert {:ok, %Account{}} = Accounts.delete(richard)
    assert_raise Ecto.NoResultsError, fn -> Repo.get!(Account, richard.id) end
  end

  test "change/1 returns a account changeset" do
    richard = insert!(:richard)
    assert %Ecto.Changeset{} = Accounts.change_account(richard)
  end
end
