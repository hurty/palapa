defmodule Palapa.Billing.BillingPlatform do
  @callback create_customer(struct, String.t()) :: {:ok, term} | {:error, term}
  @callback create_subscription(String.t(), String.t()) :: {:ok, term} | {:error, term}
end
