require Logger

defmodule Palapa.RichText.ConversionFromTrix do
  alias Palapa.RichText.{Content, EmbeddedAttachment, Tree}

  @embedded_attachment_tag "embedded-attachment"
  @trix_attachment_tag "figure"
  @trix_attachment_attribute "data-trix-attachment"
  @trix_presentation_attribute "data-trix-attributes"

  def convert(%Content{} = content) do
    content
    |> canonicalize_trix_attachments()
    |> extract_attachments

    # Parse galleries ?
  end

  def canonicalize_trix_attachments(content) do
    tree = Tree.map(content.tree, &canonicalize_trix_attachment(&1))
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
    attachments =
      content.tree
      |> find_attachments_nodes()
      |> build_embedded_attachments_structs()
      |> resolve_attachments_ids()

    Map.put(content, :embedded_attachments, attachments)
  end

  def find_attachments_nodes(nodes) do
    Floki.find(nodes, @embedded_attachment_tag)
  end

  defp build_embedded_attachments_structs(nodes) do
    Enum.map(nodes, fn {_tag, attrs, _children} ->
      struct(EmbeddedAttachment, attrs)
    end)
  end

  def resolve_attachments_ids(embedded_attachments) do
    Enum.reduce(embedded_attachments, [], fn embedded_attachment, acc ->
      embedded_attachment =
        if(EmbeddedAttachment.has_associated_attachment?(embedded_attachment)) do
          case Palapa.Access.verify_signed_id(embedded_attachment.sgid) do
            {:ok, id} ->
              Map.put(embedded_attachment, :attachment_id, id)

            _ ->
              Logger.warn(
                "Couldn't resolve attachment with sgid #{embedded_attachment.sgid}. Skipping."
              )
          end
        else
          embedded_attachment
        end

      [embedded_attachment | acc]
    end)
  end

  def decode_attribute!(json_string) do
    try do
      Jason.decode!(json_string)
    rescue
      _ -> Logger.error("Couldn't parse JSON attachment attributes : #{json_string}")
    end
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
