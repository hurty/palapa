defmodule PalapaWeb.BillingPlugTest do
  use PalapaWeb.ConnCase

  alias Palapa.Repo
  alias Palapa.Billing
  alias Palapa.Accounts.Registrations

  describe "without subscription" do
    setup do
      {:ok, %{account: account, organization_membership: membership}} =
        Registrations.create(%{
          email: "gavin.belson@hooli.com",
          name: "Gavin Belson",
          password: "password",
          organization_name: "Hooli"
        })

      conn = login(account)
      {:ok, conn: conn, organization: membership.organization}
    end

    test "lets the user pass when the workspace is 'trialing'", %{
      conn: conn,
      organization: organization
    } do
      conn = get(conn, Routes.message_path(conn, :index, organization))
      assert Billing.get_billing_status(organization) == :trialing
      assert html_response(conn, 200) =~ "Dashboard"
    end

    test "blocks the user when the trial has ended", %{conn: conn, organization: organization} do
      organization =
        organization
        |> Ecto.Changeset.change(%{inserted_at: ~N[2019-01-01 00:00:00]})
        |> Repo.update!()

      assert Billing.get_billing_status(organization) == :trial_has_ended
      assert Billing.trial_expired?(organization)
      assert Billing.workspace_frozen?(organization)

      conn =
        conn
        |> assign(:current_organization, organization)
        |> get(Routes.message_path(conn, :index, organization))

      assert redirected_to(conn, 302) =~
               Routes.billing_error_path(conn, :show, organization)
    end
  end

  describe "with subscription" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.richard)
      {:ok, conn: conn, workspace: workspace}
    end

    test "lets the user pass when the workspace is 'active'", %{conn: conn, workspace: workspace} do
      workspace.subscription
      |> Ecto.Changeset.change(%{status: :active})
      |> Repo.update!()

      conn = get(conn, Routes.message_path(conn, :index, workspace.organization))

      assert html_response(conn, 200) =~ "Dashboard"
    end

    test "blocks the user when the payment is past due", %{conn: conn, workspace: workspace} do
      workspace.subscription
      |> Ecto.Changeset.change(%{status: :past_due})
      |> Repo.update!()

      conn = get(conn, Routes.message_path(conn, :index, workspace.organization))

      assert redirected_to(conn, 302) =~
               Routes.billing_error_path(conn, :show, workspace.organization)
    end

    test "blocks the user when the subscription is canceled", %{conn: conn, workspace: workspace} do
      workspace.subscription
      |> Ecto.Changeset.change(%{status: :canceled})
      |> Repo.update!()

      conn = get(conn, Routes.message_path(conn, :index, workspace.organization))

      error_path = Routes.billing_error_path(conn, :show, workspace.organization)
      assert redirected_to(conn, 302) =~ error_path

      conn =
        login(workspace.richard)
        |> get(error_path)

      assert html_response(conn, 200) =~ "has been frozen"
    end
  end
end
