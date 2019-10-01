defmodule PalapaWeb.Authentication do
  import Plug.Conn
  import Phoenix.Controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias PalapaWeb.Router
  alias Palapa.Accounts

  def init(options) do
    options
  end

  def call(conn, _options) do
    try do
      account_id = get_session(conn, :account_id)
      account = account_id && Accounts.get!(account_id)
      conn = assign(conn, :current_account, account)

      organization_id = conn.params["organization_id"]

      organization =
        organization_id && Accounts.organization_for_account(account, organization_id)

      conn = assign(conn, :current_organization, organization)

      member = account && organization && Accounts.member_for_organization(account, organization)
      assign(conn, :current_member, member)
    rescue
      _ ->
        conn
        |> put_flash(:error, "You have been logged out")
        |> logout
    end
  end

  def enforce_authentication(conn, _options) do
    if conn.assigns[:current_account] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Router.Helpers.home_path(conn, :index))
      |> halt()
    end
  end

  def login_with_email_and_password(conn, email, password) do
    account = Accounts.get_by(email: email)

    if account && checkpw(password, account.password_hash) do
      {:ok, start_session(conn, account)}
    else
      # Avoids timing attacks
      dummy_checkpw()
      {:error, :unauthorized, conn}
    end
  end

  def start_session(conn, account) do
    conn
    |> put_session(:account_id, account.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> configure_session(drop: true)
  end
end
