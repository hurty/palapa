defmodule Palapa.Invitations.Policy do
  use Palapa.Policy

  def authorize(:create, %Member{role: role}, _) do
    role in [:admin, :owner]
  end

  def authorize(:delete, %Member{role: role}, _) do
    role in [:admin, :owner]
  end

  def authorize(:renew, %Member{role: role}, _) do
    role in [:admin, :owner]
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
