defmodule Palapa.Attachments.Policy do
  use Palapa.Policy

  def authorize(:create, %Member{}, _) do
    true
  end

  def authorize(:delete, %Member{}, _message) do
    true
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
