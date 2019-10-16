defmodule Palapa.Billing.StripityStripeAdapter do
  def create_customer(attrs) do
    custom_fields =
      if String.trim(attrs["vat_number"]) == "" do
        []
      else
        [
          %{
            name: "VAT number",
            value: attrs["vat_number"]
          }
        ]
      end

    Stripe.Customer.create(
      %{
        source: attrs["stripe_token_id"],
        email: attrs["billing_email"],
        name: attrs["billing_name"],
        address: %{
          line1: attrs["billing_address"],
          postal_code: attrs["billing_postcode"],
          city: attrs["billing_city"],
          state: attrs["billing_state"],
          country: attrs["billing_country"]
        },
        invoice_settings: %{
          custom_fields: custom_fields
        },
        metadata: %{
          customer_id: attrs["id"]
        }
      },
      expand: ["default_source"]
    )
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

  def update_customer(%Palapa.Billing.Customer{} = customer) do
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

  def create_setup_intent() do
    Stripe.SetupIntent.create(%{usage: "off_session"})
  end

  def get_payment_method(id) do
    Stripe.PaymentMethod.retrieve(id)
  end

  def update_payment_method(stripe_customer, payment_method) do
    with {:ok, payment_method} <-
           Stripe.PaymentMethod.attach(%{
             customer: stripe_customer,
             payment_method: payment_method
           }) do
      Stripe.Customer.update(stripe_customer, %{
        invoice_settings: %{default_payment_method: payment_method.id}
      })

      {:ok, payment_method}
    else
      error -> error
    end
  end

  def pay_invoice(stripe_invoice_id) do
    Stripe.Invoice.pay(stripe_invoice_id, %{})
  end
end
