defmodule Palapa.Billing do
  use Palapa.Context

  import EctoEnum

  alias Palapa.Billing
  alias Palapa.Billing.{Customer, Invoice, Subscription, StripeAdapter}

  @trial_duration_days 14
  @price_per_member_per_month 7
  @monthly_plan_id "plan_EuPumUi7Lb5R7w"

  defdelegate(authorize(action, user, params), to: Palapa.Billing.Policy)

  # Some of these statuses will be set via Stripe webhooks
  # https://stripe.com/docs/billing/lifecycle#subscription-states
  defenum(SubscriptionStatusEnum, :subscription_status, [
    :trialing,
    :incomplete,
    :incomplete_expired,
    :active,
    :past_due,
    :unpaid,
    :cancelled
  ])

  def adapter do
    StripeAdapter
  end

  # --- CUSTOMER

  def get_customer(organization = %Palapa.Organizations.Organization{}) do
    organization = Repo.preload(organization, :customer)
    organization.customer
  end

  def get_customer(id) when is_binary(id) do
    Repo.get!(Customer, id)
  end

  def get_customer_by_stripe_id!(customer_id) do
    Repo.get_by!(Customer, stripe_customer_id: customer_id)
  end

  def change_customer_infos(customer) do
    Customer.billing_infos_changeset(customer, %{})
  end

  def change_customer_payment_method(customer) do
    Customer.payment_method_changeset(customer, %{})
  end

  def create_stripe_customer(%Customer{} = customer, stripe_token_id) do
    adapter().create_customer(customer, stripe_token_id)
  end

  def update_customer_infos(customer, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:customer, Customer.edit_billing_infos_changeset(customer, attrs))
    |> Palapa.JobQueue.enqueue(:update_stripe_customer, %{
      type: "update_stripe_customer",
      customer_id: customer.id
    })
    |> Repo.transaction()
  end

  def update_stripe_customer(customer) do
    adapter().update_customer(customer)
  end

  def update_customer_payment_method(customer, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:customer, Customer.payment_method_changeset(customer, attrs))
    |> Ecto.Multi.run(:update_stripe_customer_payment_method, fn _repo,
                                                                 %{customer: customer_with_token} ->
      Billing.update_stripe_customer_payment_method(customer_with_token)
    end)
    |> Repo.transaction()
  end

  def update_stripe_customer_payment_method(customer_with_token) do
    adapter().update_payment_method(customer_with_token)
  end

  # SUBSCRIPTIONS

  def create_subscription(organization) do
    %Subscription{}
    |> change(%{organization_id: organization.id, status: :trialing})
    |> Repo.insert()
  end

  def create_stripe_subscription(stripe_customer_id) do
    adapter().create_subscription(stripe_customer_id, @monthly_plan_id)
  end

  def get_subscription_by_stripe_id!(stripe_id) do
    Repo.get_by!(Subscription, stripe_subscription_id: stripe_id)
  end

  def update_subscription(subscription, attrs) do
    subscription
    |> Subscription.changeset(attrs)
    |> Repo.update()
  end

  # --- INVOICES

  def get_invoice_by_stripe_id!(stripe_invoice_id) do
    Repo.get_by!(Invoice, stripe_invoice_id: stripe_invoice_id)
  end

  def create_invoice(customer, attrs) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> put_assoc(:customer, customer)
    |> Repo.insert(on_conflict: :nothing)
  end

  def update_invoice(invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  # --- BILLING LIFECYCLE

  def create_customer_and_synchronize_subscription(organization, customer_attrs) do
    customer_changeset =
      Customer.billing_infos_changeset(%Customer{}, customer_attrs)
      |> put_assoc(:organization, organization)

    organization = Repo.preload(organization, :subscription)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:customer, customer_changeset)
    |> Ecto.Multi.run(:stripe_customer, fn _repo, %{customer: customer} ->
      Billing.create_stripe_customer(customer, customer.stripe_token_id)
    end)
    |> Ecto.Multi.run(:stripe_subscription, fn _repo, %{stripe_customer: stripe_customer} ->
      Billing.create_stripe_subscription(stripe_customer.id)
    end)
    |> Ecto.Multi.update(:updated_customer, fn %{
                                                 stripe_subscription: stripe_subscription,
                                                 customer: customer
                                               } ->
      Billing.Customer.changeset(customer, %{
        stripe_customer_id: stripe_subscription["customer"]
      })
    end)
    |> Ecto.Multi.run(:updated_subscription, fn _repo,
                                                %{
                                                  stripe_subscription: stripe_subscription,
                                                  customer: customer
                                                } ->
      organization.subscription
      |> change(%{customer_id: customer.id, stripe_subscription: stripe_subscription["id"]})
      |> Repo.update()
    end)
    |> Repo.transaction()
  end

  def payment_next_action(stripe_subscription) do
    status = stripe_subscription["latest_invoice"]["payment_intent"]["status"]

    cond do
      status in ["requires_source_action", "requires_action"] -> :requires_action
      status == "requires_payment_method" -> :requires_payment_method
      true -> :ok
    end
  end

  def billing_information_exists?(organization) do
    !!organization.customer_id
  end

  def get_subscription_status(organization) do
    subscription = Repo.preload(organization, :subscription).subscription

    if subscription do
      subscription.status
    else
      :trialing
    end
  end

  def trial_expired?(organization) do
    trial_end = Timex.shift(organization.inserted_at, days: @trial_duration_days)
    Timex.after?(Timex.now(), trial_end)
  end

  def workspace_frozen?(organization) do
    subscription = Repo.preload(organization, :subscription).subscription

    (!subscription && trial_expired?(organization)) ||
      (subscription && subscription.status not in [:just_created, :active])
  end

  def workspace_frozen_reason(organization) do
    subscription = Repo.preload(organization, :subscription).subscription

    cond do
      !subscription && trial_expired?(organization) ->
        :trial_has_ended

      subscription && subscription.status != :active ->
        :waiting_for_payment
    end
  end

  def price_per_member_per_month do
    @price_per_member_per_month
  end

  def trial_duration_days do
    @trial_duration_days
  end

  def generate_trial_end_datetime() do
    Timex.shift(Timex.now(), days: @trial_duration_days)
  end
end
