defmodule Palapa.Billing.Subscriptions do
  use Palapa.Context

  alias Palapa.Billing
  alias Palapa.Billing.{Subscription, Customer}
  alias Palapa.Billing.Customers
  alias Ecto.Multi

  @monthly_plan_id "plan_EuPumUi7Lb5R7w"

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

  def create_subscription(organization, attrs) do
    Multi.new()
    |> validate_changeset(attrs)
    |> create_stripe_resources(attrs)
    |> create_local_resources(organization, attrs)
    |> Repo.transaction()
  end

  defp validate_changeset(multi, attrs) do
    Multi.run(multi, :changeset_validation, fn _repo, _changes ->
      changeset = Customer.changeset(%Customer{}, attrs)

      if changeset.valid? do
        {:ok, apply_changes(changeset)}
      else
        {:error, changeset}
      end
    end)
  end

  defp create_stripe_resources(multi, attrs) do
    multi
    |> Multi.run(:stripe_customer, fn _repo, _changes ->
      Customers.create_stripe_customer(attrs)
    end)
    |> Multi.run(:stripe_subscription, fn _repo, %{stripe_customer: stripe_customer} ->
      create_stripe_subscription(stripe_customer)
    end)
  end

  def create_local_resources(multi, organization, attrs) do
    multi
    |> Multi.insert(:customer, fn %{stripe_customer: stripe_customer} ->
      attrs =
        Map.merge(attrs, %{
          "stripe_customer_id" => stripe_customer.id,
          "card_brand" => stripe_customer.default_source.brand,
          "card_last_4" => stripe_customer.default_source.last4,
          "card_expiration_month" => stripe_customer.default_source.exp_month,
          "card_expiration_year" => stripe_customer.default_source.exp_year
        })

      %Customer{}
      |> Customer.changeset(attrs)
      |> put_assoc(:organization, organization)
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
    |> put_assoc(:organization, organization)
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

  def create_stripe_subscription(stripe_customer) do
    Billing.stripe_adapter().create_subscription(stripe_customer.id, @monthly_plan_id)
  end

  def get_payment_method(payment_method_id) do
    Billing.stripe_adapter().get_payment_method(payment_method_id)
  end
end
