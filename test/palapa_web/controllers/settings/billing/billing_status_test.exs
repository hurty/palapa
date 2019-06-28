defmodule PalapaWeb.Settings.Billing.BillingStatusTest do
  use PalapaWeb.ConnCase

  alias Palapa.Repo
  alias Palapa.Billing

  setup do
    workspace = insert_pied_piper!()
    conn = login(workspace.richard)
    {:ok, conn: conn, workspace: workspace}
  end

  test "lets the user pass when the workspace is 'trialing'", %{conn: conn, workspace: workspace} do
    conn = get(conn, dashboard_path(conn, :index, workspace.organization))
    assert Billing.get_workspace_status(workspace.organization) == :trialing
    assert html_response(conn, 200) =~ "Dashboard"
  end

  test "blocks the user when the trial has ended", %{conn: conn, workspace: workspace} do
    organization =
      workspace.organization
      |> Ecto.Changeset.change(%{inserted_at: ~N[2019-01-01 00:00:00]})
      |> Repo.update!()

    assert Billing.get_workspace_status(organization) == :trial_has_ended
    assert Billing.trial_expired?(organization)
    assert Billing.workspace_frozen?(organization)

    conn =
      conn
      |> assign(:current_organization, organization)
      |> get(dashboard_path(conn, :index, organization))

    assert redirected_to(conn, 302) =~ billing_error_path(conn, :show, organization)
  end

  test "lets the user pass when the workspace is 'active'", %{conn: conn, workspace: workspace} do
    active_subscription =
      workspace.subscription
      |> Ecto.Changeset.change(%{status: :active})
      |> Repo.update!()

    organization =
      workspace.organization
      |> Map.put(:subscription, active_subscription)

    assert Billing.get_workspace_status(organization) == :active
    refute Billing.workspace_frozen?(organization)

    conn =
      conn
      |> assign(:current_organization, organization)
      |> get(dashboard_path(conn, :index, organization))

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

    assert Billing.get_workspace_status(organization) == :waiting_for_payment
    assert Billing.workspace_frozen?(organization)

    conn =
      conn
      |> assign(:current_organization, organization)
      |> get(dashboard_path(conn, :index, organization))

    assert redirected_to(conn, 302) =~ billing_error_path(conn, :show, organization)
  end
end
