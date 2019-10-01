defmodule PalapaWeb.SessionController do
  use PalapaWeb, :controller

  alias PalapaWeb.Authentication
  alias Palapa.Accounts

  plug(:put_layout, "public.html")

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Authentication.login_with_email_and_password(conn, email, password) do
      {:ok, conn} ->
        conn
        |> redirect(to: Routes.organization_path(conn, :index))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Authentication.logout()
    |> redirect(to: Routes.home_path(conn, :index))
  end

  def switcher(conn, _params) do
    organizations = Accounts.list_organizations(current_account(conn))
    render(conn, "switcher.html", layout: false, organizations: organizations)
  end
end
