defmodule PalapaWeb.JoinControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Invitations
  alias Palapa.Repo, warn: false

  setup do
    workspace = insert_pied_piper!()
    conn = build_conn()
    {:ok, conn: conn, workspace: workspace}
  end

  describe "join form" do
    test "expired invitation", %{conn: conn, workspace: workspace} do
      {:ok, invitation} = Invitations.create_or_renew("dinesh@piedpiper.com", workspace.richard)

      invitation
      |> Ecto.Changeset.change(%{expire_at: DateTime.utc_now() |> DateTime.truncate(:second)})
      |> Repo.update!()

      conn = get(conn, Routes.join_path(conn, :new, invitation.id, invitation.token))
      assert html_response(conn, :forbidden) =~ "expired"
    end

    test "bad token for invitation", %{conn: conn, workspace: workspace} do
      {:ok, invitation} = Invitations.create_or_renew("dinesh@piedpiper.com", workspace.richard)
      conn = get(conn, Routes.join_path(conn, :new, invitation.id, "bad-token"))
      assert html_response(conn, :forbidden) =~ "invalid"
    end

    test "unexisting invitation", %{conn: conn, workspace: _workspace} do
      conn = get(conn, Routes.join_path(conn, :new, Ecto.UUID.generate(), "a-token"))
      assert html_response(conn, :forbidden) =~ "invalid"
    end

    test "valid invitation shows the join form", %{conn: conn, workspace: workspace} do
      {:ok, invitation} = Invitations.create_or_renew("dinesh@piedpiper.com", workspace.richard)
      conn = get(conn, Routes.join_path(conn, :new, invitation.id, invitation.token))
      assert html_response(conn, :ok) =~ "Your title"
    end
  end

  describe "join" do
    test "join without existing account", %{conn: conn, workspace: workspace} do
      {:ok, invitation} = Invitations.create_or_renew("dinesh@piedpiper.com", workspace.richard)

      count_accounts_before = Repo.count("accounts")
      count_members_before = Repo.count("members")

      conn =
        post(
          conn,
          Routes.join_path(conn, :create, invitation.id, invitation.token, %{
            "join_form" => %{
              "name" => "Dinesh",
              "password" => "password",
              "title" => "Engineer",
              "timezone" => "Europe/Paris"
            }
          })
        )

      # new account created
      count_accounts_after = Repo.count("accounts")
      assert count_accounts_after == count_accounts_before + 1

      # new member created
      count_members_after = Repo.count("members")
      assert count_members_after == count_members_before + 1

      # the user is redirected to dashboard
      assert redirected_to(conn, 302) =~
               Routes.dashboard_path(conn, :index, invitation.organization_id)

      # the user gets logged in correctly
      assert conn.assigns.current_account.email == "dinesh@piedpiper.com"
      refute is_nil(conn.assigns.current_member)

      # invitation has been deleted
      assert is_nil(Repo.reload(invitation))
    end

    test "join with an already existing account", %{conn: conn, workspace: workspace} do
      {:ok, _account} =
        Palapa.Accounts.create(%{
          name: "Dinesh",
          email: "dinesh@piedpiper.com",
          password: "password"
        })

      {:ok, invitation} = Invitations.create_or_renew("dinesh@piedpiper.com", workspace.richard)

      count_accounts_before = Repo.count("accounts")
      count_members_before = Repo.count("members")

      conn =
        post(
          conn,
          Routes.join_path(conn, :create, invitation.id, invitation.token, %{
            "join_form" => %{
              "name" => "Dinesh",
              "password" => "password",
              "title" => "Engineer",
              "timezone" => "Europe/Paris"
            }
          })
        )

      # no new account created
      count_accounts_after = Repo.count("accounts")
      assert count_accounts_after == count_accounts_before

      # new member created
      count_members_after = Repo.count("members")
      assert count_members_after == count_members_before + 1

      # the user is redirected to dashboard
      assert redirected_to(conn, 302) =~
               Routes.dashboard_path(conn, :index, invitation.organization_id)

      # the user gets logged in correctly
      assert conn.assigns.current_account.email == "dinesh@piedpiper.com"
      refute is_nil(conn.assigns.current_member)

      # invitation has been deleted
      assert is_nil(Repo.reload(invitation))
    end

    test "join but already a member of the organization", %{conn: conn, workspace: workspace} do
      {:ok, invitation} =
        Invitations.create_or_renew("bertram.gilfoyle@piedpiper.com", workspace.richard)

      count_accounts_before = Repo.count("accounts")
      count_members_before = Repo.count("members")

      conn =
        post(
          conn,
          Routes.join_path(conn, :create, invitation.id, invitation.token, %{
            "join_form" => %{
              "name" => "Bertram Gilfoyle",
              "password" => "password",
              "title" => "Engineer",
              "timezone" => "Europe/Paris"
            }
          })
        )

      # No new account created
      count_accounts_after = Repo.count("accounts")
      assert count_accounts_after == count_accounts_before

      # No new member created
      count_members_after = Repo.count("members")
      assert count_members_after == count_members_before

      # the user is redirected to dashboard
      assert redirected_to(conn, 302) =~
               Routes.dashboard_path(conn, :index, invitation.organization_id)

      # the user gets logged in correctly
      assert conn.assigns.current_account.email == "bertram.gilfoyle@piedpiper.com"
      refute is_nil(conn.assigns.current_member)

      # invitation has been deleted
      assert is_nil(Repo.reload(invitation))
    end

    test "joining with missing info displays the form again with errors", %{
      conn: conn,
      workspace: workspace
    } do
      {:ok, invitation} = Invitations.create_or_renew("dinesh@piedpiper.com", workspace.richard)

      conn =
        post(
          conn,
          Routes.join_path(conn, :create, invitation.id, invitation.token, %{
            "join_form" => %{"title" => "Engineer"}
          })
        )

      assert html_response(conn, 200) =~ "blank"
    end
  end
end
