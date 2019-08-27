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
    account_id = get_session(conn, :account_id)
    organization_id = conn.params["organization_id"]

    cond do
      conn.assigns[:current_account] ->
        conn

      account_id && organization_id ->
        try do
          account = Accounts.get!(account_id)
          organization = Accounts.organization_for_account(account, organization_id)
          member = Accounts.member_for_organization(account, organization)
          set_assigns(conn, account, organization, member)
        rescue
          _ -> clear_assigns(conn)
        end

      account_id ->
        try do
          account = Accounts.get!(account_id)
          assign(conn, :current_account, account)
        rescue
          _ -> clear_assigns(conn)
        end

      true ->
        clear_assigns(conn)
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
    {organization, member} = retrieve_context(account)

    conn
    |> put_session(:account_id, account.id)
    |> set_assigns(account, organization, member)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> clear_assigns
    |> configure_session(drop: true)
  end

  defp retrieve_context(account) do
    organization = Accounts.main_organization(account)
    member = Accounts.member_for_organization(account, organization)

    {organization, member}
  end

  defp set_assigns(conn, account, organization, member) do
    conn
    |> assign(:current_account, account)
    |> assign(:current_organization, organization)
    |> assign(:current_member, member)
  end

  defp clear_assigns(conn) do
    conn
    |> assign(:current_account, nil)
    |> assign(:current_organization, nil)
    |> assign(:current_member, nil)
  end
end
