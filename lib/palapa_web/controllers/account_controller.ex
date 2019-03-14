defmodule PalapaWeb.AccountController do
  use PalapaWeb, :controller

  alias Palapa.Accounts

  plug(:put_layout, "minimal.html")

  def edit(conn, _params) do
    conn
    |> assign_changesets(current_account())
    |> render("edit.html")
  end

  def update(conn, %{"account" => account_attrs}) do
    case Accounts.update_account(current_account(), account_attrs) do
      {:ok, account} ->
        conn
        |> assign_changesets(account)
        |> put_flash(:success, "Your account has been updated.")
        |> render("edit.html")

      {:error, account_changeset} ->
        conn
        |> assign(:account_changeset, account_changeset)
        |> assign(:password_changeset, Accounts.change_password(current_account()))
        |> put_flash(:error, "Your account could not be updated")
        |> render("edit.html")
    end
  end

  def update(conn, %{"password" => account_attrs}) do
    case Accounts.update_password(current_account(), account_attrs) do
      {:ok, account} ->
        conn
        |> assign_changesets(account)
        |> put_flash(:success, "Your password has been updated.")
        |> render("edit.html")

      {:error, password_changeset} ->
        conn
        |> assign(:account_changeset, Accounts.change_account(current_account()))
        |> assign(:password_changeset, password_changeset)
        |> put_flash(:error, "Your password could not be updated. Please check errors below.")
        |> render("edit.html")
    end
  end

  defp assign_changesets(conn, account) do
    conn
    |> assign(:account_changeset, Accounts.change_account(account))
    |> assign(:password_changeset, Accounts.change_password(account))
  end
end