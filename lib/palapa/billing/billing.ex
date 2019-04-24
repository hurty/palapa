defmodule Palapa.Billing do
  use Palapa.Context
  alias Palapa.Billing.Customer
  alias Palapa.Billing.StripeAdapter

  @trial_duration_days 14
  @grace_period_days 15
  @price_per_member_per_month 7

  def adapter do
    StripeAdapter
  end

  def create_customer(organization, attrs) do
    Customer.changeset(%Customer{}, attrs)
    |> put_assoc(:organization, organization)
    |> Repo.insert()

    # sync with stripe in a background job
  end

  def update_customer(customer, attrs) do
    Customer.changeset(customer, attrs)
    |> Repo.update()
  end

  def billing_information_exists?(organization) do
    !!organization.customer_id
  end

  def valid?(organization) do
    if is_nil(organization.valid_until) do
      true
    else
      grace_period_end = Timex.shift(organization.valid_until, days: @grace_period_days)
      Timex.after?(Timex.now(), grace_period_end)
    end
  end

  def organization_state(organization) do
    cond do
      valid?(organization) &&
          !billing_information_exists?(organization) ->
        :trial

      !valid?(organization) &&
          !billing_information_exists?(organization) ->
        :trial_has_ended

      !valid?(organization) && billing_information_exists?(organization) ->
        :waiting_for_payment

      valid?(organization) ->
        :ok

      true ->
        :unknown_state
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
