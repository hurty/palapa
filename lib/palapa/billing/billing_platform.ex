defmodule Palapa.Billing.BillingPlatform do
  @callback create_customer(struct) :: {:ok, term} | {:error, term}
  @callback create_subscription(struct, String.t()) :: {:ok, term} | {:error, term}
end
