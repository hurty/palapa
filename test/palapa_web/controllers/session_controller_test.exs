defmodule PalapaWeb.SessionControllerTest do
  use PalapaWeb.ConnCase

  describe "login" do
    setup do
      conn = build_conn()
      {:ok, conn: conn}
    end

    test "visitors can see the login form", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign in"
    end

    test "a member logins successfully", %{conn: conn} do
      insert!(:owner)

      conn =
        post(conn, Routes.session_path(conn, :create), %{
          "session" => %{
            "email" => "richard.hendricks@piedpiper.com",
            "password" => "password"
          }
        })

      assert redirected_to(conn, 302) =~ Routes.organization_path(conn, :index)

      assert conn.assigns.current_account
    end

    test "cannot login with a bad password", %{conn: conn} do
      insert!(:owner)

      conn =
        post(conn, Routes.session_path(conn, :create), %{
          "session" => %{
            "email" => "richard.hendricks@piedpiper.com",
            "password" => "wrong"
          }
        })

      assert html_response(conn, 200) =~ "Sign in"
      assert get_flash(conn, :error) == "Invalid email/password combination"
      refute conn.assigns.current_account
    end

    test "cannot login with a unknown email", %{conn: conn} do
      insert!(:owner)

      conn =
        post(conn, Routes.session_path(conn, :create), %{
          "session" => %{
            "email" => "unknown@isp.com",
            "password" => "password"
          }
        })

      assert html_response(conn, 200) =~ "Sign in"
      assert get_flash(conn, :error) == "Invalid email/password combination"
      refute conn.assigns.current_account
    end
  end

  describe "logout" do
    setup do
      member = insert!(:member)

      conn =
        build_conn()
        |> assign(:current_member, member)
        |> assign(:current_account, member.account)
        |> assign(:current_organization, member.organization)

      {:ok, conn: conn, member: member}
    end

    test "a member logout destroys his session", %{conn: conn} do
      conn = delete(conn, Routes.session_path(conn, :delete))

      assert redirected_to(conn, 302) == Routes.home_path(conn, :index)
      refute conn.assigns.current_account
    end
  end
end
