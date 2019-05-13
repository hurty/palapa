defmodule Palapa.Billing.StripeAdapter do
  @behaviour Palapa.Billing.BillingPlatform

  def create_customer(customer, stripe_token_id) do
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
        custom_fields: [
          %{
            name: "VAT number",
            value: customer.vat_number
          }
        ]
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
    Stripe.Subscription.create(%{
      customer: stripe_customer_id,
      items: [
        %{
          plan: stripe_plan_id
        }
      ]
    })
  end
end
