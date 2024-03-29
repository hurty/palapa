defmodule Palapa.Billing.Subscriptions do
  use Palapa.Context

  alias Palapa.Billing
  alias Palapa.Billing.{Subscription, Customer}
  alias Palapa.Billing.Customers
  alias Ecto.Multi

  # Returns a local %Billing.Subscription{}
  def get_subscription_by_stripe_id!(stripe_id) do
    Repo.get_by!(Subscription, stripe_subscription_id: stripe_id)
  end

  def get_subscription(%Organization{} = organization) do
    Repo.get_assoc(organization, :subscription)
  end

  def update_subscription(subscription, attrs) do
    subscription
    |> Subscription.changeset(attrs)
    |> Repo.update()
  end

  def refresh_local_subscription_status(%Organization{} = organization) do
    subscription = get_subscription(organization)

    case Billing.stripe_adapter().get_subscription(subscription.stripe_subscription_id) do
      {:ok, stripe_subscription} ->
        update_subscription(subscription, %{
          status: stripe_subscription.status,
          stripe_latest_invoice_id: stripe_subscription.latest_invoice.id
        })

      error ->
        error
    end
  end

  def create_subscription(%Organization{} = organization, %Customer{} = customer) do
    Multi.new()
    |> Multi.run(:stripe_subscription, fn _repo, _changes ->
      create_stripe_subscription(customer.stripe_customer_id, trial_end(organization))
    end)
    |> Multi.run(:subscription, fn _repo, %{stripe_subscription: stripe_subscription} ->
      create_subscription(organization, customer, %{
        status: stripe_subscription["status"],
        stripe_subscription_id: stripe_subscription["id"],
        stripe_latest_invoice_id: get_in(stripe_subscription, ["latest_invoice", "id"])
      })
    end)
    |> Repo.transaction()
  end

  def create_subscription(%Organization{} = organization, attrs) when is_map(attrs) do
    Multi.new()
    |> validate_changeset(attrs)
    |> create_stripe_resources(organization, attrs)
    |> create_local_resources(organization, attrs)
    |> Repo.transaction()
  end

  defp trial_end(organization) do
    if Billing.get_billing_status(organization) == :trialing do
      Billing.trial_end(organization)
    else
      nil
    end
  end

  defp validate_changeset(multi, attrs) do
    Multi.run(multi, :changeset_validation, fn _repo, _changes ->
      Customer.changeset(%Customer{}, attrs)
      |> apply_action(:insert)
    end)
  end

  defp create_stripe_resources(multi, organization, attrs) do
    multi
    |> Multi.run(:stripe_customer, fn _repo, _changes ->
      Customers.create_stripe_customer(attrs)
    end)
    |> Multi.run(:stripe_subscription, fn _repo, %{stripe_customer: stripe_customer} ->
      create_stripe_subscription(stripe_customer, trial_end(organization))
    end)
  end

  def create_local_resources(multi, organization, attrs) do
    multi
    |> Multi.insert(:customer, fn %{stripe_customer: stripe_customer} ->
      card = stripe_customer.invoice_settings.default_payment_method.card

      attrs =
        Map.merge(attrs, %{
          "stripe_customer_id" => stripe_customer.id,
          "card_brand" => card.brand,
          "card_last_4" => card.last4,
          "card_expiration_month" => card.exp_month,
          "card_expiration_year" => card.exp_year
        })

      %Customer{}
      |> Customer.changeset(attrs)
    end)
    |> Multi.run(:subscription, fn _repo,
                                   %{customer: customer, stripe_subscription: stripe_subscription} ->
      create_subscription(organization, customer, %{
        status: stripe_subscription["status"],
        stripe_subscription_id: stripe_subscription["id"],
        stripe_latest_invoice_id: get_in(stripe_subscription, ["latest_invoice", "id"])
      })
    end)
  end

  def create_subscription(organization, customer, attrs) do
    %Subscription{}
    |> cast(attrs, [:status, :stripe_subscription_id, :stripe_latest_invoice_id])
    |> put_assoc(:organizations, [organization])
    |> put_assoc(:customer, customer)
    |> Repo.insert()
  end

  def cancel_subscription(organization) do
    organization
    |> get_subscription()
    |> cancel_stripe_subscription()
  end

  # Stripe resources

  def cancel_stripe_subscription(%{stripe_subscription_id: stripe_id})
      when is_binary(stripe_id) do
    Billing.stripe_adapter().cancel_subscription(stripe_id)
  end

  def cancel_stripe_subscription(nil), do: {:ok, nil}

  def create_stripe_subscription(%Stripe.Customer{} = stripe_customer, trial_end) do
    monthly_plan_id = Application.get_env(:palapa, :stripe_plan_id)
    Billing.stripe_adapter().create_subscription(stripe_customer.id, monthly_plan_id, trial_end)
  end

  def create_stripe_subscription(stripe_customer_id, trial_end)
      when is_binary(stripe_customer_id) do
    monthly_plan_id = Application.get_env(:palapa, :stripe_plan_id)
    Billing.stripe_adapter().create_subscription(stripe_customer_id, monthly_plan_id, trial_end)
  end

  def get_payment_method(payment_method_id) do
    Billing.stripe_adapter().get_payment_method(payment_method_id)
  end
end
