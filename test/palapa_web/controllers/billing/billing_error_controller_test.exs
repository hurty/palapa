defmodule PalapaWeb.Billing.BillingErrorControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Billing
  alias Ecto.Changeset
  alias Palapa.Repo

  describe "As owner of the workspace" do
    setup do
      workspace = insert_pied_piper!()
      conn = login(workspace.richard)

      {:ok, conn: conn, workspace: workspace}
    end

    test "no subscription/no trial", %{conn: conn, workspace: workspace} do
      Repo.delete!(workspace.subscription)

      workspace.organization
      |> Changeset.change(%{allow_trial: false})
      |> Repo.update!()

      conn = get(conn, Routes.billing_error_path(conn, :show, workspace.organization))

      assert redirected_to(conn, 302) =~
               Routes.subscription_path(conn, :new, workspace.organization)
    end

    test "expired subscription", %{conn: conn, workspace: workspace} do
      workspace.subscription
      |> Changeset.change(%{status: :incomplete_expired})
      |> Repo.update!()

      conn = get(conn, Routes.billing_error_path(conn, :show, workspace.organization))

      assert redirected_to(conn, 302) =~
               Routes.subscription_path(conn, :new, workspace.organization)
    end

    test "trialing", %{conn: conn, workspace: workspace} do
      conn = get(conn, Routes.billing_error_path(conn, :show, workspace.organization))

      assert redirected_to(conn, 302) =~
               Routes.dashboard_path(conn, :index, workspace.organization)
    end

    test "end of trial", %{conn: conn, workspace: workspace} do
      Repo.delete!(workspace.subscription)

      two_months_ago =
        Timex.now()
        |> Timex.shift(months: -2)

      organization =
        workspace.organization
        |> Changeset.cast(%{inserted_at: two_months_ago, allow_trial: true}, [
          :inserted_at,
          :allow_trial
        ])
        |> Repo.update!()

      assert Billing.get_billing_status(organization) == :trial_has_ended
      conn = get(conn, Routes.billing_error_path(conn, :show, organization))
      assert html_response(conn, 200) =~ "trial period has ended"
    end

    test "active subscription", %{conn: conn, workspace: workspace} do
      conn = get(conn, Routes.billing_error_path(conn, :show, workspace.organization))

      assert redirected_to(conn, 302) =~
               Routes.dashboard_path(conn, :index, workspace.organization)
    end

    test "past due subscription", %{conn: conn, workspace: workspace} do
      workspace.subscription
      |> Changeset.change(%{status: :past_due})
      |> Repo.update!()

      conn = get(conn, Routes.billing_error_path(conn, :show, workspace.organization))

      assert html_response(conn, 200) =~
               "An owner of the workspace must update the billing information"
    end

    test "canceled subscription", %{conn: conn, workspace: workspace} do
      workspace.subscription
      |> Changeset.change(%{status: :canceled})
      |> Repo.update!()

      conn = get(conn, Routes.billing_error_path(conn, :show, workspace.organization))

      assert html_response(conn, 200) =~
               "An owner of the workspace must update the billing information"
    end
  end
end
