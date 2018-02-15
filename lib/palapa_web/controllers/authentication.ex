defmodule PalapaWeb.Authentication do
  import Plug.Conn
  import Phoenix.Controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias PalapaWeb.Router

  def init(options) do
    options
  end

  def call(conn, _options) do
    member_id = get_session(conn, :member_id)
    organization_id = get_session(conn, :organization_id)

    cond do
      member = conn.assigns[:current_member] ->
        conn

      member_id && organization_id ->
        organization = Palapa.Organizations.get!(organization_id)
        member = Palapa.Organizations.get_member!(organization, member_id)

        conn
        |> assign(:current_member, member)
        |> assign(:current_organization, organization)

      true ->
        assign(conn, :current_member, nil)
    end
  end

  def login(conn, member, organization) do
    conn
    |> assign(:current_member, member)
    |> put_session(:member_id, member.id)
    |> assign(:organization, organization)
    |> put_session(:organization_id, organization.id)
    |> configure_session(renew: true)
  end

  def login(conn, account) do
    organization = Palapa.Accounts.main_organization(account)
    member = Palapa.Accounts.member_for_organization(account, organization)

    login(conn, member, organization)
  end

  def login_with_email_and_password(conn, email, password) do
    account = Palapa.Accounts.get_by(email: email)

    cond do
      account && checkpw(password, account.password_hash) ->
        {:ok, login(conn, account)}

      true ->
        # Avoids timing attacks
        dummy_checkpw()
        {:error, :unauthorized, conn}
    end
  end

  def switch_organization(conn, organization) do
    conn
    |> assign(:organization, organization)
    |> put_session(:organization_id, organization.id)
    |> configure_session(renew: true)
    |> redirect(to: Router.Helpers.dashboard_path(conn, :index))
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def authenticate_member(conn, _options) do
    if conn.assigns[:current_member] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Router.Helpers.home_path(conn, :index))
      |> halt()
    end
  end

  def current_member(conn) do
    conn.assigns.current_member
  end

  def current_organization(conn) do
    conn.assigns.current_organization
  end
end
