defmodule PalapaWeb.AuthenticationTest do
  use PalapaWeb.ConnCase
  alias PalapaWeb.Authentication

  @registration %{
    email: "richard.hendricks@piedpiper.com",
    name: "Richard Hendricks",
    password: "password",
    organization_name: "Pied Piper"
  }

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(PalapaWeb.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "enforce_authentication halts when no current_account exists", %{conn: conn} do
    conn = Authentication.enforce_authentication(conn, [])
    assert conn.halted
  end

  test "enforce_authentication continues when the current account is set",
       %{conn: conn} do
    conn =
      conn
      |> assign(:current_account, %Palapa.Accounts.Account{})
      |> Authentication.enforce_authentication([])

    refute conn.halted
  end

  test "start_session puts the user in the session", %{conn: conn} do
    {:ok, %{account: account}} = Palapa.Accounts.Registrations.create(@registration)

    login_conn =
      conn
      |> Authentication.start_session(account)
      |> send_resp(:ok, "")

    assert get_session(login_conn, :account_id) == account.id
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:account_id, 123)
      |> Authentication.logout()
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :account_id)
  end

  test "call/2 places the current account into assigns", %{conn: conn} do
    {:ok, %{account: account}} = Palapa.Accounts.Registrations.create(@registration)

    conn =
      conn
      |> put_session(:account_id, account.id)
      |> Authentication.call([])

    assert conn.assigns.current_account.id == account.id
  end

  test "call/2 with no session set current_account assign to nil", %{conn: conn} do
    conn = Authentication.call(conn, [])
    assert conn.assigns.current_account == nil
  end

  test "login with valid email and password", %{conn: conn} do
    {:ok, %{account: account}} = Palapa.Accounts.Registrations.create(@registration)

    {:ok, conn} =
      Authentication.login_with_email_and_password(
        conn,
        "richard.hendricks@piedpiper.com",
        "password"
      )

    assert get_session(conn, :account_id) == account.id
  end

  test "login with an unknown user", %{conn: conn} do
    assert {:error, :unauthorized, _conn} =
             Authentication.login_with_email_and_password(
               conn,
               "unknown.account@none.com",
               "password"
             )
  end

  test "login with password mismatch", %{conn: conn} do
    {:ok, _} = Palapa.Accounts.Registrations.create(@registration)

    assert {:error, :unauthorized, _conn} =
             Authentication.login_with_email_and_password(
               conn,
               "richard.hendricks@piedpiper.com",
               "wrong_pass"
             )
  end
end
