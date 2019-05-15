defmodule Palapa.Billing do
  use Palapa.Context

  alias Palapa.Billing
  alias Palapa.Billing.Customer
  alias Palapa.Billing.StripeAdapter

  @trial_duration_days 14
  @grace_period_days 14
  @price_per_member_per_month 7
  @monthly_plan_id "plan_EuPumUi7Lb5R7w"

  defdelegate(authorize(action, user, params), to: Palapa.Billing.Policy)

  def adapter do
    StripeAdapter
  end

  def get_customer(organization = %Palapa.Organizations.Organization{}) do
    organization = Repo.preload(organization, :customer)
    organization.customer
  end

  def get_customer(id) when is_binary(id) do
    Repo.get!(Customer, id)
  end

  def change_customer_infos(customer) do
    Customer.billing_infos_changeset(customer, %{})
  end

  def create_customer_infos(organization, customer_attrs) do
    customer_changeset =
      Customer.billing_infos_changeset(%Customer{}, customer_attrs)
      |> put_assoc(:organizations, [organization])

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:customer, customer_changeset)
    |> Ecto.Multi.run(:stripe_customer, fn _repo, %{customer: customer} ->
      Billing.create_stripe_customer(customer, customer.stripe_token_id)
    end)
    |> Ecto.Multi.run(:stripe_subscription, fn _repo, %{stripe_customer: stripe_customer} ->
      Billing.create_stripe_subscription(stripe_customer.id)
    end)
    |> Ecto.Multi.update(:updated_customer, fn %{
                                                 customer: customer,
                                                 stripe_subscription: stripe_subscription
                                               } ->
      Billing.Customer.changeset(customer, %{
        stripe_subscription_id: stripe_subscription["id"],
        stripe_customer_id: stripe_subscription["customer"]
      })
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

  def create_stripe_customer(%Customer{} = customer, stripe_token_id) do
    adapter().create_customer(customer, stripe_token_id)
  end

  def create_stripe_subscription(stripe_customer_id) do
    adapter().create_subscription(stripe_customer_id, @monthly_plan_id)
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

  def billing_information_exists?(organization) do
    !!organization.customer_id
  end

  def valid?(organization) do
    if is_nil(organization.valid_until) do
      true
    else
      grace_period_end = Timex.shift(organization.valid_until, days: @grace_period_days)
      Timex.after?(grace_period_end, Timex.now())
    end
  end

  def organization_state(organization) do
    cond do
      valid?(organization) && billing_information_exists?(organization) ->
        :ok

      valid?(organization) &&
          !billing_information_exists?(organization) ->
        :trial

      !valid?(organization) && billing_information_exists?(organization) ->
        :waiting_for_payment

      !valid?(organization) &&
          !billing_information_exists?(organization) ->
        :trial_has_ended

      true ->
        :unknown
    end
  end

  def organization_frozen?(organization) do
    organization_state(organization) not in [:trial, :ok]
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
