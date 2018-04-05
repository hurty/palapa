defmodule Palapa.Messages.Policy do
  use Palapa.Policy

  def authorize(:create, %Member{}, _) do
    true
  end

  def authorize(:show, %Member{}, _) do
    true
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
