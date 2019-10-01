defmodule PalapaWeb.Settings.Billing.BillingStatusTest do
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
      conn = get(conn, Routes.dashboard_path(conn, :index, organization))
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
        |> get(Routes.dashboard_path(conn, :index, organization))

      assert redirected_to(conn, 302) =~
               Routes.settings_billing_error_path(conn, :show, organization)
    end
  end

  describe "with subscription" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.richard)
      {:ok, conn: conn, workspace: workspace}
    end

    test "lets the user pass when the workspace is 'active'", %{conn: conn, workspace: workspace} do
      active_subscription =
        workspace.subscription
        |> Ecto.Changeset.change(%{status: :active})
        |> Repo.update!()

      organization =
        workspace.organization
        |> Map.put(:subscription, active_subscription)

      assert Billing.get_billing_status(organization) == :active
      refute Billing.workspace_frozen?(organization)

      conn =
        conn
        |> assign(:current_organization, organization)
        |> get(Routes.dashboard_path(conn, :index, organization))

      assert html_response(conn, 200) =~ "Dashboard"
    end

    test "blocks the user when the payment is past due", %{conn: conn, workspace: workspace} do
      past_due_subscription =
        workspace.subscription
        |> Ecto.Changeset.change(%{status: :past_due})
        |> Repo.update!()

      organization =
        workspace.organization
        |> Map.put(:subscription, past_due_subscription)

      assert Billing.workspace_frozen?(organization)

      conn =
        conn
        |> assign(:current_organization, organization)
        |> get(Routes.dashboard_path(conn, :index, organization))

      assert redirected_to(conn, 302) =~
               Routes.settings_billing_error_path(conn, :show, organization)
    end
  end
end
