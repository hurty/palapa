defmodule Palapa.Invitations.Policy do
  @behaviour Bodyguard.Policy

  alias Palapa.Organizations.Member

  def authorize(:create, %Member{role: role}, _) do
    role in [:admin, :owner]
  end
end
