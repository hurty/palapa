defmodule Palapa.Billing.Policy do
  use Palapa.Policy

  def authorize(:create_customer, member, organization) do
    member.role == :owner && is_nil(organization.subscription_id)
  end

  def authorize(:update_billing, member, _attrs) do
    member.role == :owner
  end
end
