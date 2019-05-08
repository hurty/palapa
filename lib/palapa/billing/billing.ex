defmodule Palapa.Billing do
  use Palapa.Context
  alias Palapa.Billing.Customer
  alias Palapa.Billing.StripeAdapter

  @trial_duration_days 14
  @grace_period_days 14
  @price_per_member_per_month 7

  def adapter do
    StripeAdapter
  end

  def get_customer(organization) do
    organization = Repo.preload(organization, :customer)
    organization.customer
  end

  def change_customer_infos(customer) do
    Customer.billing_infos_changeset(customer, %{})
  end

  def create_customer_infos(organization, attrs) do
    Customer.billing_infos_changeset(%Customer{}, attrs)
    |> put_assoc(:organizations, [organization])
    |> Repo.insert()

    # sync with stripe in a background job
  end

  def update_customer_infos(customer, attrs) do
    Customer.billing_infos_changeset(customer, attrs)
    |> Repo.update()

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
