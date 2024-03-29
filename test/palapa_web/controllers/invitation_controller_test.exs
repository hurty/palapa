defmodule PalapaWeb.InvitationControllerTest do
  use PalapaWeb.ConnCase
  alias Palapa.Repo

  alias Palapa.Invitations
  alias Palapa.Invitations.Invitation

  describe "as regular member" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.gilfoyle)
      {:ok, conn: conn, member: workspace.gilfoyle, org: workspace.organization}
    end

    test "regular members can't access the invitation page", %{conn: conn, org: org} do
      conn = get(conn, Routes.invitation_path(conn, :new, org))
      assert html_response(conn, :forbidden)
    end

    test "regular members can't invite people", %{conn: conn, org: org} do
      conn =
        post(conn, Routes.invitation_path(conn, :create, org), %{
          "invitation" => %{"email_addresses" => ""}
        })

      assert html_response(conn, :forbidden)
    end

    test "regular members can't cancel an invitation", %{conn: conn, member: member, org: org} do
      {:ok, invitation} = Invitations.create_or_renew("dinesh@piedpiper.com", member)
      conn = delete(conn, Routes.invitation_path(conn, :delete, org, invitation))

      assert html_response(conn, :forbidden)
    end
  end

  describe "as admin" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.jared)
      {:ok, conn: conn, member: workspace.jared, org: workspace.organization}
    end

    test "admin can access the invitation page", %{conn: conn, org: org} do
      conn = get(conn, Routes.invitation_path(conn, :new, org))
      assert html_response(conn, 200) =~ "Invite people"
    end

    test "admin can invite people", %{conn: conn, org: org} do
      count_invitations_before = Repo.count("invitations")

      conn =
        post(conn, Routes.invitation_path(conn, :create, org), %{
          "invitation" => %{"email_addresses" => "laurie@piedpiper.com"}
        })

      count_invitations_after = Repo.count("invitations")

      assert_in_delta(count_invitations_before, count_invitations_after, 1)
      assert html_response(conn, 302)
      assert get_flash(conn, :success) == "Invitations have been sent"
    end

    test "malformed email addresses are ignored", %{conn: conn, org: org} do
      count_invitations_before = Repo.count("invitations")

      conn =
        post(conn, Routes.invitation_path(conn, :create, org), %{
          "invitation" => %{"email_addresses" => "bertram.gilfoyle@piedpiper.com bad_address"}
        })

      count_invitations_after = Repo.count("invitations")

      assert html_response(conn, 200) =~ "Make sure addresses are correct"
      assert_in_delta(count_invitations_before, count_invitations_after, 1)
    end

    test "addresses field can't be empty", %{conn: conn, org: org} do
      count_invitations_before = Repo.count("invitations")

      conn =
        post(conn, Routes.invitation_path(conn, :create, org), %{
          "invitation" => %{"email_addresses" => ""}
        })

      count_invitations_after = Repo.count("invitations")

      assert html_response(conn, 302)
      assert get_flash(conn, :error) == "You must enter at least one email address"
      assert count_invitations_before == count_invitations_after
    end

    test "an admin can cancel an invitation", %{conn: conn, member: member, org: org} do
      {:ok, invitation} = Palapa.Invitations.create_or_renew("dinesh@piedpiper.com", member)
      count_invitations_before = Repo.count(Invitation)
      conn = delete(conn, Routes.invitation_path(conn, :delete, org, invitation))
      count_invitations_after = Repo.count(Invitation)

      assert conn.status == 204
      assert count_invitations_after == count_invitations_before - 1
    end

    test "an admin can renew an invitation", %{conn: conn, member: member, org: org} do
      {:ok, invitation} = Palapa.Invitations.create_or_renew("dinesh@piedpiper.com", member)
      count_invitations_before = Repo.count(Invitation)
      conn = post(conn, Routes.invitation_renew_path(conn, :renew, org, invitation))
      count_invitations_after = Repo.count(Invitation)

      assert redirected_to(conn, 302) =~ Routes.invitation_path(conn, :new, org)
      assert get_flash(conn, :success) =~ "dinesh@piedpiper.com has been sent a new invitation"
      assert count_invitations_after == count_invitations_before
    end
  end

  describe "as owner" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.richard)
      {:ok, conn: conn, member: workspace.richard, org: workspace.organization}
    end

    test "the owner can access the invitation page", %{conn: conn, org: org} do
      conn = get(conn, Routes.invitation_path(conn, :new, org))
      assert html_response(conn, 200) =~ "Invite people"
    end

    test "the owner can invite people", %{conn: conn, org: org} do
      count_invitations_before = Repo.count("invitations")

      conn =
        post(conn, Routes.invitation_path(conn, :create, org), %{
          "invitation" => %{"email_addresses" => "laurie@piedpiper.com"}
        })

      count_invitations_after = Repo.count("invitations")

      assert html_response(conn, 302)
      assert get_flash(conn, :success) == "Invitations have been sent"
      assert_in_delta(count_invitations_before, count_invitations_after, 1)
    end

    test "the owner can cancel an invitation", %{conn: conn, member: member, org: org} do
      {:ok, invitation} = Palapa.Invitations.create_or_renew("dinesh@piedpiper.com", member)
      count_invitations_before = Repo.count(Invitation)
      conn = delete(conn, Routes.invitation_path(conn, :delete, org, invitation))
      count_invitations_after = Repo.count(Invitation)

      assert conn.status == 204
      assert count_invitations_after == count_invitations_before - 1
    end

    test "the owner can renew an invitation", %{conn: conn, member: member, org: org} do
      {:ok, invitation} = Palapa.Invitations.create_or_renew("dinesh@piedpiper.com", member)
      count_invitations_before = Repo.count(Invitation)
      conn = post(conn, Routes.invitation_renew_path(conn, :renew, org, invitation))
      count_invitations_after = Repo.count(Invitation)

      assert redirected_to(conn, 302) =~ Routes.invitation_path(conn, :new, org)
      assert get_flash(conn, :success) =~ "dinesh@piedpiper.com has been sent a new invitation"
      assert count_invitations_after == count_invitations_before
    end
  end
end
