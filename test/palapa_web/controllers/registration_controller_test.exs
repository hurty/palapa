defmodule PalapaWeb.RegistrationControllerTest do
  use PalapaWeb.ConnCase

  setup do
    insert_pied_piper!()
    {:ok, conn: build_conn()}
  end

  test "successful registration", %{conn: conn} do
    conn =
      post(conn, Routes.registration_path(conn, :create), %{
        "registration" => %{
          "organization_name" => "Hooli",
          "name" => "Gavin Belson",
          "email" => "gavin@hooli.com",
          "password" => "12345"
        }
      })

    assert html_response(conn, 200) =~ "should be at least 8 character(s)"
  end

  test "account already exists", %{conn: conn} do
    conn =
      post(conn, Routes.registration_path(conn, :create), %{
        "registration" => %{"email" => "richard.hendricks@piedpiper.com"}
      })

    assert redirected_to(conn, 302) =~ Routes.session_path(conn, :new)
    assert get_flash(conn, :error) =~ "It seems you already have a Palapa account"
  end

  test "fields are missing", %{conn: conn} do
    conn =
      post(conn, Routes.registration_path(conn, :create), %{
        "registration" => %{}
      })

    assert html_response(conn, 200) =~ "Check the errors"
  end

  test "password should be at least 8 chars", %{conn: conn} do
    conn =
      post(conn, Routes.registration_path(conn, :create), %{
        "registration" => %{"password" => "12345"}
      })

    assert html_response(conn, 200) =~ "should be at least 8 character(s)"
  end
end
