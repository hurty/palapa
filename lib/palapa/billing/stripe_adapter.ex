defmodule Palapa.Billing.StripeAdapter do
  @behaviour Palapa.Billing.BillingPlatform

  @montly_plan_id "plan_EsBkLn7BGeJMDN"

  def create_customer(account) do
    Stripe.Customer.create(%{
      email: account.email,
      description: account.name,
      metadata: %{account_id: account.id}
    })
  end

  @doc """
  Link a customer to an already defined Stripe plan
  The trial period is handled on Stripe's side.
  """
  def create_subscription(account, organization) do
    Stripe.Subscription.create(%{
      customer: account.customer_id,
      items: [
        %{
          plan: @montly_plan_id,
          metadata: %{
            account_id: account.id,
            organization_id: organization.id,
            organization_name: organization.name
          }
        }
      ]
    })
  end
end
