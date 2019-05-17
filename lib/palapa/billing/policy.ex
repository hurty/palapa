defmodule Palapa.Billing.Policy do
  use Palapa.Policy

  def authorize(:update_billing, member, _attrs) do
    member.role == :owner
  end
end
