require IEx

defmodule PalapaWeb.AuthenticationTest do
  use PalapaWeb.ConnCase
  alias PalapaWeb.Authentication

  @registration %{
    email: "pierre.hurtevent@gmail.com",
    name: "Pierre Hurtevent",
    password: "password",
    organization_name: "PalapaCorp"
  }

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(PalapaWeb.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Authentication.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user continues when the current_user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Palapa.Accounts.User{})
      |> Authentication.authenticate_user([])

    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    {:ok, %{user: user}} = Palapa.Accounts.create_registration(@registration)

    login_conn =
      conn
      |> Authentication.login(user)
      |> send_resp(:ok, "")

    assert get_session(login_conn, :user_id) == user.id
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Authentication.logout()
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call places the current user into assigns", %{conn: conn} do
    {:ok, %{user: user, organization: organization}} =
      Palapa.Accounts.create_registration(@registration)

    conn =
      conn
      |> put_session(:user_id, user.id)
      |> put_session(:organization_id, organization.id)
      |> Authentication.call([])

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session set current_user assign to nil", %{conn: conn} do
    conn = Authentication.call(conn, [])
    assert conn.assigns.current_user == nil
  end

  test "login with valid email and password", %{conn: conn} do
    {:ok, %{user: user}} = Palapa.Accounts.create_registration(@registration)

    {:ok, conn} =
      Authentication.login_with_email_and_password(conn, "pierre.hurtevent@gmail.com", "password")

    assert conn.assigns.current_user.id == user.id
  end

  test "login with an unknown user", %{conn: conn} do
    assert {:error, :unauthorized, _conn} =
             Authentication.login_with_email_and_password(conn, "unknown@user.com", "password")
  end

  test "login with password mismatch", %{conn: conn} do
    {:ok, _} = Palapa.Accounts.create_registration(@registration)

    assert {:error, :unauthorized, _conn} =
             Authentication.login_with_email_and_password(
               conn,
               "pierre.hurtevent@gmail.com",
               "wrong_pass"
             )
  end
end
