defmodule Palapa.Billing.Customers do
  use Palapa.Context

  alias Palapa.Billing
  alias Palapa.Billing.{Customer, Subscription}
  alias Palapa.Organizations.Organization
  alias Palapa.Accounts.Account

  # Local resources

  def get_customer(%Organization{} = organization) do
    Repo.get_assoc(organization, :customer)
  end

  def get_customer(queryable \\ Customer, id) when is_binary(id) do
    Repo.get(queryable, id)
  end

  def get_customer_by_stripe_id!(customer_id) do
    Repo.get_by!(Customer, stripe_customer_id: customer_id)
  end

  def change_customer(customer) do
    Customer.update_changeset(customer, %{})
  end

  def update_customer(customer, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:customer, Customer.update_changeset(customer, attrs))
    |> Oban.insert(
      :update_stripe_customer,
      Billing.Workers.UpdateStripeCustomer.new(%{customer_id: customer.id})
    )
    |> Repo.transaction()
  end

  def change_customer_payment_method(%Organization{} = organization) do
    organization = Repo.preload(organization, :customer)
    change_customer_payment_method(organization.customer)
  end

  def change_customer_payment_method(%Customer{} = customer) do
    Customer.payment_method_changeset(customer, %{})
  end

  def update_customer_payment_method(customer, stripe_payment_method_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:stripe_payment_method, fn _repo, _ ->
      update_stripe_customer_payment_method(customer, stripe_payment_method_id)
    end)
    |> Ecto.Multi.update(:customer, fn %{stripe_payment_method: payment_method} ->
      pm_attrs = %{
        card_brand: payment_method.card.brand,
        card_expiration_month: payment_method.card.exp_month,
        card_expiration_year: payment_method.card.exp_year,
        card_last_4: payment_method.card.last4
      }

      Customer.payment_method_changeset(customer, pm_attrs)
    end)
    |> Repo.transaction()
  end

  def reusable_customer_accounts(%Account{} = account) do
    organizations = Organizations.active_organizations_having_owner(account)

    from(customers in Customer,
      inner_join: subscriptions in Subscription,
      on: subscriptions.customer_id == customers.id,
      where: subscriptions.status == "active",
      inner_join: organizations in subquery(organizations),
      distinct: true
    )
  end

  def list_reusable_customer_accounts(%Account{} = account) do
    reusable_customer_accounts(account)
    |> Repo.all()
  end

  # Stripe resources

  def create_stripe_customer(attrs) do
    Billing.stripe_adapter().create_customer(attrs)
  end

  def update_stripe_customer(customer) do
    Billing.stripe_adapter().update_customer(customer)
  end

  def update_stripe_customer_payment_method(customer, stripe_payment_method_id) do
    Billing.stripe_adapter().update_payment_method(
      customer.stripe_customer_id,
      stripe_payment_method_id
    )
  end
end
