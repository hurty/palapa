defmodule PalapaWeb.Settings.Billing.StripeWebhookControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Billing

  setup do
    workspace = insert_pied_piper!()

    {:ok, conn: build_conn(), workspace: workspace}
  end

  test "invalid stripe signature", %{conn: conn} do
    conn =
      conn
      |> Plug.Conn.put_req_header("stripe-signature", "something bad")
      |> post(stripe_webhook_path(conn, :create))

    assert response(conn, :forbidden)
  end

  @invoice_created_event %Stripe.Event{
    type: "invoice.created",
    data: %{
      object: %{
        id: "in_000",
        created_at: 1_560_763_806,
        customer: "cus_123",
        number: "ABC123",
        status: "open",
        total: 2900,
        hosted_invoice_url: "https://pay.stripe.com/invoice/invst_GkUH2ES1UzkOOc9L4Iip6xIQH2",
        invoice_pdf: "https://pay.stripe.com/invoice/invst_GkUH2ES1UzkOOc9L4Iip6xIQH2/pdf"
      }
    }
  }
  test "an invoice has been created", %{conn: conn} do
    conn =
      conn
      |> assign(:ignore_stripe_signature, true)
      |> assign(:event, @invoice_created_event)
      |> post(stripe_webhook_path(conn, :create))

    assert response(conn, :ok)
    invoice = Billing.get_invoice_by_stripe_id!("in_000")
    assert invoice.status == "open"
  end

  @invoice_payment_succeeded_event %Stripe.Event{
    type: "invoice.payment_succeeded",
    data: %{
      object: %{
        id: "in_000",
        created_at: 1_560_763_806,
        customer: "cus_123",
        number: "ABC123",
        status: "paid",
        total: 2900,
        hosted_invoice_url: "https://pay.stripe.com/invoice/invst_GkUH2ES1UzkOOc9L4Iip6xIQH2",
        invoice_pdf: "https://pay.stripe.com/invoice/invst_GkUH2ES1UzkOOc9L4Iip6xIQH2/pdf"
      }
    }
  }
  test "an invoice payment succeeded", %{conn: conn, workspace: workspace} do
    insert!(:invoice,
      organization: workspace.organization,
      stripe_invoice_id: "in_000",
      status: "open"
    )

    conn =
      conn
      |> assign(:ignore_stripe_signature, true)
      |> assign(:event, @invoice_payment_succeeded_event)
      |> post(stripe_webhook_path(conn, :create))

    assert response(conn, :ok)
    invoice = Billing.get_invoice_by_stripe_id!("in_000")
    assert invoice.status == "paid"
  end

  @subscription_updated_event %Stripe.Event{
    type: "customer.subscription.updated",
    data: %{
      object: %{
        id: "sub_000",
        customer: "cus_123",
        status: "active"
      }
    }
  }
  test "a subscription has been updated", %{conn: conn, workspace: workspace} do
    conn =
      conn
      |> assign(:ignore_stripe_signature, true)
      |> assign(:event, @subscription_updated_event)
      |> post(stripe_webhook_path(conn, :create))

    subscription = Palapa.Repo.preload(workspace.organization, :subscription).subscription
    assert response(conn, :ok)
    assert subscription.status == :active
  end
end
