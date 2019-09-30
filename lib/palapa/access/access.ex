defmodule Palapa.Access do
  def generate_token(length \\ 48) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  def hash_string(string) do
    :crypto.hash(:sha256, string) |> Base.encode16() |> String.downcase()
  end

  def generate_signed_id(id) do
    # We do this to avoid compile time dependencies.
    endpoint = Module.concat([PalapaWeb, "Endpoint"])
    Phoenix.Token.sign(endpoint, "signed-id-salt", id)
  end

  def verify_signed_id(signed_id) do
    # We do this to avoid compile time dependencies.
    endpoint = Module.concat([PalapaWeb, "Endpoint"])
    Phoenix.Token.verify(endpoint, "signed-id-salt", signed_id, max_age: 2_592_000)
  end

  def verified_signed_id?(signed_id) do
    case verify_signed_id(signed_id) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
