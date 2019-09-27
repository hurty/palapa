defmodule PalapaWeb.PasswordResetControllerTest do
  use PalapaWeb.ConnCase
  use Bamboo.Test, shared: true

  setup do
    workspace = insert_pied_piper!()
    conn = build_conn()
    {:ok, conn: conn, workspace: workspace}
  end

  test "get the password reset form", %{conn: conn} do
    conn = get(conn, Routes.password_reset_path(conn, :new))
    assert html_response(conn, 200) =~ "Password reset"
  end

  test "ask for a reset link with an existing email", %{conn: conn} do
    payload = %{"password_reset" => %{"email" => "richard.hendricks@piedpiper.com"}}
    conn = post(conn, Routes.password_reset_path(conn, :create, payload))
    assert html_response(conn, 200) =~ "An email has been sent"
    assert_email_delivered_with(to: [nil: "richard.hendricks@piedpiper.com"])
  end

  test "ask for a reset link with non-existing email", %{conn: conn} do
    payload = %{"password_reset" => %{"email" => "bad@mail.org"}}
    conn = post(conn, Routes.password_reset_path(conn, :create, payload))

    # We pretend everyting went well in order not to disclose existing accounts
    assert html_response(conn, 200) =~ "An email has been sent"
    assert_no_emails_delivered()
  end

  test "ask for a reset link with invalid email address", %{conn: conn} do
    payload = %{"password_reset" => %{"email" => "invalidmail.org"}}
    conn = post(conn, Routes.password_reset_path(conn, :create, payload))
    assert html_response(conn, 200) =~ "Please enter a valid email address"
    assert_no_emails_delivered()
  end

  test "use link with secret token to display reset password form", %{
    conn: conn,
    workspace: workspace
  } do
    {:ok, token} = Palapa.Accounts.generate_password_reset_token(workspace.richard.account)
    conn = get(conn, Routes.password_reset_path(conn, :edit, %{"password_reset_token" => token}))
    assert html_response(conn, 200)
  end

  test "reset password successfully", %{conn: conn, workspace: workspace} do
    {:ok, token} = Palapa.Accounts.generate_password_reset_token(workspace.richard.account)

    payload = %{
      "password" => %{
        "password" => "p4ssw0rd",
        "password_confirmation" => "p4ssw0rd",
        "password_reset_token" => token
      }
    }

    conn = patch(conn, Routes.password_reset_path(conn, :update, payload))
    assert redirected_to(conn, 302)
  end

  test "reset password too short", %{conn: conn, workspace: workspace} do
    {:ok, token} = Palapa.Accounts.generate_password_reset_token(workspace.richard.account)

    payload = %{
      "password" => %{
        "password" => "p4ss",
        "password_confirmation" => "p4ss",
        "password_reset_token" => token
      }
    }

    conn = patch(conn, Routes.password_reset_path(conn, :update, payload))
    assert html_response(conn, 200) =~ "should be at least 8 character(s)"
  end

  test "reset password wrong confirmation", %{conn: conn, workspace: workspace} do
    {:ok, token} = Palapa.Accounts.generate_password_reset_token(workspace.richard.account)

    payload = %{
      "password" => %{
        "password" => "p4ssw0rd",
        "password_confirmation" => "p4sswoooord",
        "password_reset_token" => token
      }
    }

    conn = patch(conn, Routes.password_reset_path(conn, :update, payload))
    assert html_response(conn, 200) =~ "Password confirmation does not match"
  end

  test "reset password with invalid token", %{conn: conn, workspace: workspace} do
    {:ok, _token} = Palapa.Accounts.generate_password_reset_token(workspace.richard.account)

    payload = %{
      "password" => %{
        "password" => "p4ssw0rd",
        "password_confirmation" => "p4ssw0rd",
        "password_reset_token" => "INVALID_TOKEN"
      }
    }

    conn = patch(conn, Routes.password_reset_path(conn, :update, payload))
    assert html_response(conn, 200) =~ "This reset token is invalid"
  end

  test "reset password with expired token", %{conn: conn, workspace: workspace} do
    {:ok, token} = Palapa.Accounts.generate_password_reset_token(workspace.richard.account)
    yesterday = Timex.now() |> Timex.shift(days: -1) |> DateTime.truncate(:second)

    workspace.richard.account
    |> Ecto.Changeset.change(%{password_reset_at: yesterday})
    |> Palapa.Repo.update!()

    payload = %{
      "password" => %{
        "password" => "p4ssw0rd",
        "password_confirmation" => "p4ssw0rd",
        "password_reset_token" => token
      }
    }

    conn = patch(conn, Routes.password_reset_path(conn, :update, payload))
    assert html_response(conn, 200) =~ "This reset token is invalid"
  end
end
