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

  test "authenticate_account halts when no current_account exists", %{conn: conn} do
    conn = Authentication.authenticate_account(conn, [])
    assert conn.halted
  end

  test "authenticate_account continues when the current_account exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_account, %Palapa.Accounts.Account{})
      |> Authentication.authenticate_account([])

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

  test "call places the current user into assigns", %{conn: conn} do
    {:ok, %{account: account, organization: organization, member: member}} =
      Palapa.Accounts.Registrations.create(@registration)

    conn =
      conn
      |> put_session(:account_id, account.id)
      |> put_session(:organization_id, organization.id)
      |> put_session(:member_id, member.id)
      |> Authentication.call([])

    assert conn.assigns.current_account.id == account.id
    assert conn.assigns.current_organization.id == organization.id
    assert conn.assigns.current_member.id == member.id
  end

  test "call with no session set current_account assign to nil", %{conn: conn} do
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

    assert conn.assigns.current_account.id == account.id
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
