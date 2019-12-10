defmodule PalapaWeb.AccountController do
  use PalapaWeb, :controller

  alias Palapa.Accounts

  plug(:put_layout, "account.html")
  plug(:put_navigation, "account")

  def edit(conn, _params) do
    conn
    |> assign_changesets(current_account(conn))
    |> render("edit.html")
  end

  def update(conn, %{"account" => account_attrs}) do
    case Accounts.update_account(current_account(conn), account_attrs) do
      {:ok, %{account: account}} ->
        conn
        |> assign_changesets(account)
        |> put_flash(:success, gettext("Your account has been updated."))
        # Force redirect to set the new locale
        |> put_session(:locale, nil)
        |> redirect(to: Routes.account_path(conn, :edit))

      {:error, :account, account_changeset, _changes} ->
        conn
        |> assign(:account_changeset, account_changeset)
        |> assign(:password_changeset, Accounts.change_password(current_account(conn)))
        |> put_flash(:error, gettext("Your account could not be updated"))
        |> render("edit.html")
    end
  end

  def update(conn, %{"password" => account_attrs}) do
    case Accounts.update_password(current_account(conn), account_attrs) do
      {:ok, account} ->
        conn
        |> assign_changesets(account)
        |> put_flash(:success, gettext("Your password has been updated."))
        |> render("edit.html")

      {:error, password_changeset} ->
        conn
        |> assign(:account_changeset, Accounts.change_account(current_account(conn)))
        |> assign(:password_changeset, password_changeset)
        |> put_flash(
          :error,
          gettext("Your password could not be updated. Please check errors below.")
        )
        |> render("edit.html")
    end
  end

  def delete(conn, _params) do
    case Accounts.delete(current_account(conn)) do
      {:ok, _account} ->
        conn
        |> put_flash(:success, "Your account has been deleted.")
        |> PalapaWeb.Authentication.logout()
        |> redirect(to: Routes.home_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(
          :error,
          gettext("An error occured while deleting your account. Please contact support.")
        )
        |> render("edit.html")
    end
  end

  defp assign_changesets(conn, account) do
    conn
    |> assign(:account_changeset, Accounts.change_account(account))
    |> assign(:password_changeset, Accounts.change_password(account))
  end
end
