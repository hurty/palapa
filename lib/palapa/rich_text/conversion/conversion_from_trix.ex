require Logger

defmodule Palapa.RichText.ConversionFromTrix do
  alias Palapa.RichText.{Content, EmbeddedAttachment}

  @embedded_attachment_tag "embedded-attachment"
  @trix_attachment_tag "figure"
  @trix_attachment_attribute "data-trix-attachment"
  @trix_presentation_attribute "data-trix-attributes"

  def convert(%Content{} = content) do
    content
    |> canonicalize_trix_attachments()
    |> extract_attachments
    |> mark_as_resolved()
  end

  def canonicalize_trix_attachments(content) do
    tree = Floki.traverse_and_update(content.tree, &canonicalize_trix_attachment(&1))
    Map.put(content, :tree, tree)
  end

  def canonicalize_trix_attachment({@trix_attachment_tag, attrs, rest}) do
    if has_trix_attributes?(attrs) do
      transformed_attrs = transform_trix_attachment_attrs(attrs)
      {@embedded_attachment_tag, transformed_attrs, []}
    else
      {@trix_attachment_tag, attrs, rest}
    end
  end

  def canonicalize_trix_attachment(other_tag), do: other_tag

  def has_trix_attributes?(attrs) do
    attrs
    |> Keyword.keys()
    |> Enum.member?(@trix_attachment_attribute)
  end

  def transform_trix_attachment_attrs(attachment_attrs) do
    attachment_attrs
    |> Enum.filter(fn {attr_name, _attr_value} ->
      attr_name == @trix_attachment_attribute || attr_name == @trix_presentation_attribute
    end)
    |> Enum.map(fn {_attr_name, attr_value} ->
      decode_attribute!(attr_value)
    end)
    |> Enum.reduce(&Map.merge(&1, &2))
    |> atomize_keys()
  end

  def extract_attachments(content) do
    embedded_attachments =
      content.tree
      |> find_attachments_nodes()
      |> build_embedded_attachments_structs()

    content = Map.put(content, :embedded_attachments, embedded_attachments)

    associated_attachments =
      embedded_attachments
      |> resolve_attachments()
      |> retrieve_associated_attachments()

    Map.put(content, :attachments, associated_attachments)
  end

  def find_attachments_nodes(nodes) do
    Floki.find(nodes, @embedded_attachment_tag)
  end

  defp build_embedded_attachments_structs(nodes) do
    Enum.map(nodes, fn {_tag, attrs, _children} ->
      struct(EmbeddedAttachment, attrs)
    end)
  end

  def resolve_attachments(embedded_attachments) do
    Enum.reduce(embedded_attachments, [], fn embedded_attachment, acc ->
      [EmbeddedAttachment.resolve(embedded_attachment) | acc]
    end)
  end

  def retrieve_associated_attachments(embedded_attachments) do
    embedded_attachments
    |> Enum.map(& &1.attachment)
    |> Enum.reject(&is_nil(&1))
  end

  def decode_attribute!(json_string) do
    try do
      Jason.decode!(json_string)
    rescue
      _ -> Logger.error("Couldn't parse JSON attachment attributes : #{json_string}")
    end
  end

  def mark_as_resolved(content) do
    Map.put(content, :attachments_resolved, true)
  end

  defp atomize_keys(string_keys_map) do
    Map.new(string_keys_map, fn {key, value} ->
      atom_key =
        key
        |> Macro.underscore()
        |> String.to_atom()

      {atom_key, to_string(value)}
    end)
  end
end
