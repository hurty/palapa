defmodule Palapa.Access do
  import Ecto.Query

  def scope(query, organization) do
    query
    |> where(organization_id: ^organization.id)
  end

  def scope_by_ids(query, ids) when is_list(ids) do
    query
    |> where([q], q.id in ^ids)
  end

  def generate_token(length \\ 48) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  def hash_string(string) do
    :crypto.hash(:sha256, string) |> Base.encode16() |> String.downcase()
  end

  def generate_signed_id(id) do
    Phoenix.Token.sign(PalapaWeb.Endpoint, "signed-id-salt", id)
  end

  def verify_signed_id(signed_id) do
    Phoenix.Token.verify(PalapaWeb.Endpoint, "signed-id-salt", signed_id, max_age: 2_592_000)
  end

  def verified_signed_id?(signed_id) do
    case verify_signed_id(signed_id) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
