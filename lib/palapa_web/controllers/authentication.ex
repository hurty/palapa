defmodule PalapaWeb.Authentication do
  import Plug.Conn
  import Phoenix.Controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias PalapaWeb.Router
  alias Palapa.Accounts
  alias Palapa.Organizations

  def init(options) do
    options
  end

  def call(conn, _options) do
    account_id = get_session(conn, :account_id)
    organization_id = get_session(conn, :organization_id)
    member_id = get_session(conn, :member_id)

    cond do
      member = conn.assigns[:current_member] ->
        conn

      account_id && organization_id && member_id ->
        member = Organizations.get_member_with_account!(member_id)

        conn
        |> assign(:current_account, member.account)
        |> assign(:current_organization, member.organization)
        |> assign(:current_member, member)

      true ->
        conn
        |> assign(:current_account, nil)
        |> assign(:current_organization, nil)
        |> assign(:current_member, nil)
    end
  end

  def authenticate_account(conn, _options) do
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
    organization = Accounts.main_organization(account)
    member = Accounts.member_for_organization(account, organization)

    start_session(conn, account, organization, member)
  end

  def start_session(conn, account, organization, member) do
    conn
    |> assign(:current_account, account)
    |> put_session(:account_id, account.id)
    |> assign(:current_organization, organization)
    |> put_session(:organization_id, organization.id)
    |> assign(:current_member, member)
    |> put_session(:member_id, member.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> assign(:current_account, nil)
    |> assign(:current_organization, nil)
    |> assign(:current_member, nil)
    |> configure_session(drop: true)
  end

  def current_member(conn) do
    conn.assigns.current_member
  end

  def current_organization(conn) do
    conn.assigns.current_organization
  end

  def switch_organization(conn, organization) do
    conn
    |> assign(:organization, organization)
    |> put_session(:organization_id, organization.id)
    |> configure_session(renew: true)
    |> redirect(
      to: Router.Helpers.dashboard_path(conn, :index, conn.assigns.current_organization)
    )
  end
end
