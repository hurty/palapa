defmodule PalapaWeb.PasswordResetControllerTest do
  use PalapaWeb.ConnCase
  use Bamboo.Test, shared: true

  alias Palapa.Repo

  setup do
    workspace = insert_pied_piper!()
    conn = build_conn()
    {:ok, conn: conn, workspace: workspace}
  end

  test "get the password reset form", %{conn: conn} do
    conn = get(conn, password_reset_path(conn, :new))
    assert html_response(conn, 200) =~ "Password reset"
  end

  test "ask for a reset link with an existing email", %{conn: conn, workspace: workspace} do
    payload = %{"password_reset" => %{"email" => "richard.hendricks@piedpiper.com"}}
    conn = post(conn, password_reset_path(conn, :create, payload))
    assert html_response(conn, 200) =~ "An email has been sent"
    assert_email_delivered_with(to: [nil: "richard.hendricks@piedpiper.com"])
  end

  test "ask for a reset link with non-existing email", %{conn: conn, workspace: workspace} do
    payload = %{"password_reset" => %{"email" => "bad@mail.org"}}
    conn = post(conn, password_reset_path(conn, :create, payload))

    # We pretend everyting went well in order not to disclose existing accounts
    assert html_response(conn, 200) =~ "An email has been sent"
    assert_no_emails_delivered()
  end

  test "ask for a reset link with invalid email address", %{conn: conn, workspace: workspace} do
    payload = %{"password_reset" => %{"email" => "invalidmail.org"}}
    conn = post(conn, password_reset_path(conn, :create, payload))
    assert html_response(conn, 200) =~ "Please enter a valid email address"
    assert_no_emails_delivered()
  end
end
