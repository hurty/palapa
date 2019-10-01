defmodule PalapaWeb.AccountControllerTest do
  use PalapaWeb.ConnCase

  describe "change account settings" do
    setup do
      account = insert!(:jared)
      conn = login(account)

      {:ok, conn: conn, account: account}
    end

    test "get account settings form", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :edit))
      assert html_response(conn, 200) =~ "Your account"
    end

    test "change accounts settings successfully", %{conn: conn} do
      conn =
        patch(conn, Routes.account_path(conn, :update), %{
          "account" => %{
            "name" => "John",
            "email" => "john@isp.com",
            "timezone" => "Europe/Paris"
          }
        })

      assert html_response(conn, 200) =~ "Your account has been updated"
    end

    test "cannot change account settings without an email", %{conn: conn} do
      conn =
        patch(conn, Routes.account_path(conn, :update), %{
          "account" => %{
            "name" => "John",
            "email" => "",
            "timezone" => "Europe/Paris"
          }
        })

      assert html_response(conn, 200) =~ "Your account could not be updated"
    end
  end

  describe "change account password" do
    setup do
      account = insert!(:jared)
      conn = login(account)

      {:ok, conn: conn, account: account}
    end

    test "wrong current password", %{conn: conn} do
      conn =
        patch(conn, Routes.account_path(conn, :update), %{
          "password" => %{
            "current_password" => "wrong_one",
            "password" => "newPassword",
            "password_confirmation" => "newPassword"
          }
        })

      assert html_response(conn, 200) =~ "Your password could not be updated"
    end

    test "wrong password confirmation", %{conn: conn} do
      conn =
        patch(conn, Routes.account_path(conn, :update), %{
          "password" => %{
            "current_password" => "password",
            "password" => "newPassword",
            "password_confirmation" => "newPasswordWrong"
          }
        })

      assert html_response(conn, 200) =~ "Your password could not be updated"
    end

    test "successful password change", %{conn: conn} do
      conn =
        patch(conn, Routes.account_path(conn, :update), %{
          "password" => %{
            "current_password" => "password",
            "password" => "newPassword",
            "password_confirmation" => "newPassword"
          }
        })

      assert html_response(conn, 200) =~ "Your password has been updated"
    end
  end
end
