defmodule Palapa.RichText.Type do
  @behaviour Ecto.Type

  alias Palapa.RichText
  alias Palapa.RichText.Content

  def type, do: :string

  # handle the conversion from external data to runtime data
  def cast(rich_text) when is_binary(rich_text) do
    {:ok, RichText.from_trix(rich_text)}
  end

  def cast(_), do: :error

  # load from the database
  def load(data) when is_binary(data) do
    {:ok, RichText.load(data)}
  end

  # dump to the database
  def dump(%Content{} = content) do
    {:ok, RichText.to_html(content)}
  end

  def dump(content) when is_binary(content) do
    {:ok, content}
  end

  def dump(_), do: :error
end
