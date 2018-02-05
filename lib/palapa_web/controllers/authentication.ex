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
    user_id = get_session(conn, :user_id)
    organization_id = get_session(conn, :organization_id)

    cond do
      user = conn.assigns[:current_user] ->
        conn

      user = user_id && organization_id && Accounts.get_user!(user_id) ->
        organization = Accounts.get_organization!(organization_id)

        conn
        |> assign(:current_user, user)
        |> assign(:current_organization, organization)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user, organization) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> assign(:organization, organization)
    |> put_session(:organization_id, organization.id)
    |> configure_session(renew: true)
  end

  def login(conn, user) do
    organization = Accounts.get_user_main_organization!(user)
    login(conn, user, organization)
  end

  def login_with_email_and_password(conn, email, password) do
    user = Accounts.get_user_by(email: email)

    cond do
      user && checkpw(password, user.password_hash) ->
        {:ok, login(conn, user)}

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

  def authenticate_user(conn, _options) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Router.Helpers.home_path(conn, :index))
      |> halt()
    end
  end

  def current_user(conn) do
    conn.assigns.current_user
  end

  def current_organization(conn) do
    conn.assigns.current_organization
  end
end
