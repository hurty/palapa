defmodule Palapa.Billing do
  use Palapa.Context
  import EctoEnum

  alias Palapa.Billing

  @trial_duration_days 14
  @price_per_member_per_month 7

  # These statuses will be set via Stripe webhooks
  # https://stripe.com/docs/billing/lifecycle#subscription-states
  # The trial period is not handled by Stripe so there is no "trialing" status for subscriptions on palapa's side.
  defenum(SubscriptionStatusEnum, :subscription_status, [
    :incomplete,
    :incomplete_expired,
    :active,
    :past_due,
    :canceled
  ])

  defmodule BillingError do
    defexception [:message]
  end

  def stripe_adapter do
    Palapa.Billing.StripityStripeAdapter
  end

  def create_setup_intent() do
    stripe_adapter().create_setup_intent()
  end

  def get_payment_intent(stripe_subscription_id) do
    {:ok, stripe_subscription} = stripe_adapter().get_subscription(stripe_subscription_id)
    stripe_subscription.latest_invoice.payment_intent
  end

  def price_per_member_per_month do
    @price_per_member_per_month
  end

  def trial_duration_days do
    @trial_duration_days
  end

  def billing_information_exists?(organization) do
    !!organization.customer_id
  end

  def get_billing_status(organization) do
    subscription = Repo.get_assoc(organization, :subscription)

    cond do
      organization.allow_trial && is_nil(subscription) && !trial_expired?(organization) ->
        :trialing

      organization.allow_trial && is_nil(subscription) && trial_expired?(organization) ->
        :trial_has_ended

      subscription ->
        subscription.status

      true ->
        :none
    end
  end

  def trial_expired?(organization) do
    trial_end = Timex.shift(organization.inserted_at, days: @trial_duration_days)
    Timex.after?(Timex.now(), trial_end)
  end

  def trial_remaining_days(organization) do
    trial_end = Timex.shift(organization.inserted_at, days: @trial_duration_days)
    Timex.diff(trial_end, Timex.now(), :days)
  end

  def workspace_frozen?(organization) do
    Billing.get_billing_status(organization) not in [:trialing, :active]
  end
end
