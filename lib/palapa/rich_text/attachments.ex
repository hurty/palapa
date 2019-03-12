require Logger

defmodule Palapa.RichText.Attachments do
  alias Palapa.RichText.EmbeddedAttachment

  @attachment_tag_name "rich-text-attachment"
  @trix_attachment_tag "figure"
  @trix_attachment_attribute "data-trix-attachment"
  @trix_presentation_attribute "data-trix-attributes"

  def find_attachments(nodes) do
    find_attachments_nodes(nodes)
    |> extract_attachments_attributes()
    |> resolve_attachments()
    |> IO.inspect()
  end

  def find_attachments_nodes(nodes) do
    Floki.find(nodes, @trix_attachment_tag)
    |> Enum.filter(fn node -> node_is_embedded_attachment?(node) end)
  end

  def node_is_embedded_attachment?(node) do
    Floki.attribute(node, @trix_attachment_tag, @trix_attachment_attribute)
    |> Enum.any?()
  end

  def extract_attachments_attributes(nodes) do
    Enum.reduce(nodes, [], fn node, acc ->
      attachment_attrs =
        Floki.attribute(node, @trix_attachment_attribute)
        |> decode_attribute!()

      presentation_attrs =
        Floki.attribute(node, @trix_presentation_attribute)
        |> decode_attribute!()

      embedded_attachment =
        Map.merge(attachment_attrs, presentation_attrs)
        |> build_embedded_attachments_struct()

      [embedded_attachment | acc]
    end)
  end

  def resolve_attachments(embedded_attachments) do
    Enum.reduce(embedded_attachments, [], fn embedded_attachment, acc ->
      embedded_attachment =
        case Palapa.Access.verify_signed_id(embedded_attachment.sgid) do
          {:ok, id} ->
            embedded_attachment
            |> Map.put(:id, id)
            |> Map.put(:missing, false)

          _ ->
            embedded_attachment
            |> Map.put(:missing, true)
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

  def build_embedded_attachments_struct(attachment_map) do
    attachment_map = atomize_keys(attachment_map)
    struct(EmbeddedAttachment, attachment_map)
  end

  def atomize_keys(string_keys_map) do
    Map.new(string_keys_map, fn {key, value} ->
      atom_key =
        key
        |> Macro.underscore()
        |> String.to_atom()

      {atom_key, value}
    end)
  end

  def transform_embedded_attachments(nodes) do
    Floki.map(nodes, fn node ->
      if node_is_embedded_attachment?(node) do
        {_tag_name, attrs} = node
        {@attachment_tag_name, attrs}
      else
        node
      end
    end)
  end
end
