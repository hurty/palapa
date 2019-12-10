defmodule PalapaWeb.Authentication do
  import Plug.Conn
  import Phoenix.Controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Palapa.Gettext
  alias PalapaWeb.Router
  alias Palapa.Accounts
  alias Palapa.Organizations

  def init(options) do
    options
  end

  def call(conn, _options) do
    if conn.assigns[:current_account] do
      conn
    else
      try do
        account_id = get_session(conn, :account_id)
        account = account_id && Accounts.get!(account_id)
        assign(conn, :current_account, account)
      rescue
        _ ->
          conn
          |> put_flash(:error, gettext("You have been logged out"))
          |> logout
      end
    end
  end

  def put_organization_context(conn, _options) do
    account = conn.assigns[:current_account]
    organization = Organizations.get!(conn.params["organization_id"])
    member = Organizations.get_member_from_account(organization, account)

    Bodyguard.permit!(Organizations.Policy, :access_organization, member, organization)

    if Organizations.soft_deleted?(organization) do
      conn
      |> put_flash(
        :error,
        gettext("The workspace %{workspace} has been deleted", %{
          workspace: organization.name
        })
      )
      |> redirect(to: Router.Helpers.organization_path(conn, :index))
      |> halt()
    else
      member = organization && Accounts.member_for_organization(account, organization)

      conn
      |> assign(:current_organization, organization)
      |> assign(:current_member, member)
    end
  end

  def enforce_authentication(conn, _options) do
    if conn.assigns[:current_account] do
      conn
    else
      conn
      |> put_flash(:error, gettext("You must be logged in to access that page"))
      |> redirect(to: Router.Helpers.home_path(conn, :index))
      |> halt()
    end
  end

  def login_with_email_and_password(conn, email, password) do
    account = Accounts.active(Accounts.Account) |> Accounts.get_by(email: email)

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
    |> assign(:current_account, account)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> assign(:current_account, nil)
    |> configure_session(drop: true)
  end
end
