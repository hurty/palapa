defmodule PalapaWeb.InvitationControllerTest do
  use PalapaWeb.ConnCase
  alias Palapa.Repo

  describe "as regular member" do
    setup do
      member = insert!(:member)
      conn = login(member)
      {:ok, conn: conn, member: member}
    end

    test "regular members can't access the invitation page", %{conn: conn} do
      conn = get(conn, invitation_path(conn, :new))
      assert html_response(conn, :forbidden)
    end

    test "regular members can't invite people", %{conn: conn} do
      conn =
        post(conn, invitation_path(conn, :create), %{"invitation" => %{"email_addresses" => ""}})

      assert html_response(conn, :forbidden)
    end
  end

  describe "as admin" do
    setup do
      member = insert!(:admin)
      conn = login(member)
      {:ok, conn: conn, member: member}
    end

    test "admin can access the invitation page", %{conn: conn} do
      conn = get(conn, invitation_path(conn, :new))
      assert html_response(conn, 200) =~ "Invite people"
    end

    test "admin can invite people", %{conn: conn} do
      count_invitations_before = Repo.count("invitations")

      conn =
        post(conn, invitation_path(conn, :create), %{
          "invitation" => %{"email_addresses" => "bertram.gilfoyle@piedpiper.com"}
        })

      count_invitations_after = Repo.count("invitations")

      assert html_response(conn, 302)
      assert get_flash(conn, :success) == "Invitations have been sent"
      assert_in_delta(count_invitations_before, count_invitations_after, 1)
    end

    test "malformed email addresses are ignored", %{conn: conn} do
      count_invitations_before = Repo.count("invitations")

      conn =
        post(conn, invitation_path(conn, :create), %{
          "invitation" => %{"email_addresses" => "bertram.gilfoyle@piedpiper.com bad_address"}
        })

      count_invitations_after = Repo.count("invitations")

      assert html_response(conn, 200) =~ "1 invitation(s) couldn't be sent"
      assert_in_delta(count_invitations_before, count_invitations_after, 1)
    end

    test "addresses field can't be empty", %{conn: conn} do
      count_invitations_before = Repo.count("invitations")

      conn =
        post(conn, invitation_path(conn, :create), %{
          "invitation" => %{"email_addresses" => ""}
        })

      count_invitations_after = Repo.count("invitations")

      assert html_response(conn, 302)
      assert get_flash(conn, :error) == "You must enter at least one email address"
      assert count_invitations_before == count_invitations_after
    end
  end

  describe "as owner" do
    setup do
      member = insert!(:owner)
      conn = login(member)
      {:ok, conn: conn, member: member}
    end

    test "owner can access the invitation page", %{conn: conn} do
      conn = get(conn, invitation_path(conn, :new))
      assert html_response(conn, 200) =~ "Invite people"
    end

    test "admin can invite people", %{conn: conn} do
      count_invitations_before = Repo.count("invitations")

      conn =
        post(conn, invitation_path(conn, :create), %{
          "invitation" => %{"email_addresses" => "bertram.gilfoyle@piedpiper.com"}
        })

      count_invitations_after = Repo.count("invitations")

      assert html_response(conn, 302)
      assert get_flash(conn, :success) == "Invitations have been sent"
      assert_in_delta(count_invitations_before, count_invitations_after, 1)
    end
  end
end
