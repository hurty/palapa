defmodule Palapa.Billing.StripeAdapter do
  @behaviour Palapa.Billing.BillingPlatform

  def create_customer(customer, stripe_token_id) do
    custom_fields =
      if customer.vat_number do
        [
          %{
            name: "VAT number",
            value: customer.vat_number
          }
        ]
      else
        []
      end

    Stripe.Customer.create(%{
      source: stripe_token_id,
      email: customer.billing_email,
      name: customer.billing_name,
      address: %{
        line1: customer.billing_address,
        postal_code: customer.billing_postcode,
        city: customer.billing_city,
        state: customer.billing_state,
        country: customer.billing_country
      },
      invoice_settings: %{
        custom_fields: custom_fields
      },
      metadata: %{
        customer_id: customer.id
      }
    })
  end

  @doc """
  Link a customer to an already defined Stripe plan
  """
  def create_subscription(stripe_customer_id, stripe_plan_id) do
    # "latest_invoice" attribute doesn't seem to be correctly
    # handled by StripityStripe for now. Fallback to manual here.
    body = %{
      enable_incomplete_payments: true,
      customer: stripe_customer_id,
      items: [
        %{
          plan: stripe_plan_id
        }
      ]
    }

    Stripe.API.request(body, :post, "subscriptions", %{},
      expand: ["latest_invoice.payment_intent"]
    )
  end

  def get_subscription(stripe_subscription_id) do
    Stripe.Subscription.retrieve(stripe_subscription_id, expand: ["latest_invoice.payment_intent"])
  end

  def update_customer(customer) do
    custom_fields =
      if customer.vat_number do
        [
          %{
            name: "VAT number",
            value: customer.vat_number
          }
        ]
      else
        []
      end

    customer_attrs = %{
      email: customer.billing_email,
      name: customer.billing_name,
      address: %{
        line1: customer.billing_address,
        postal_code: customer.billing_postcode,
        city: customer.billing_city,
        state: customer.billing_state,
        country: customer.billing_country
      },
      invoice_settings: %{
        custom_fields: custom_fields
      }
    }

    Stripe.Customer.update(customer.stripe_customer_id, customer_attrs)
  end

  def update_payment_method(customer) do
    body = %{source: customer.stripe_token_id}

    Stripe.Customer.update(customer.stripe_customer_id, body,
      expand: ["subscriptions.data.latest_invoice.payment_intent"]
    )
  end

  def pay_invoice(stripe_invoice_id) do
    Stripe.Invoice.pay(stripe_invoice_id, %{})
  end
end
