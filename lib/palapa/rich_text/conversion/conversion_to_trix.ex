defmodule Palapa.RichText.ConversionToTrix do
  alias Palapa.RichText.{Content}

  @embedded_attachment_tag "embedded-attachment"

  def convert(%Content{} = content) do
    content
    |> render_attachments()
  end

  defp render_attachments(content) do
    tree = Floki.traverse_and_update(content.tree, &render_attachment(&1))
    Map.put(content, :tree, tree)
  end

  defp render_attachment({tag, attrs, rest}) do
    if tag == @embedded_attachment_tag do
      attrs =
        Enum.into(attrs, %{}, fn {k, v} ->
          if is_atom(k) do
            {k, v}
          else
            {String.to_atom(k), v}
          end
        end)

      trix_formatted_attrs = [
        {"data-trix-attachment", data_trix_attachment(attrs)},
        {"data-trix-content-type", Map.get(attrs, :content_type)},
        {"data-trix-attributes", data_trix_attributes(attrs)}
      ]

      {"figure", trix_formatted_attrs, []}
    else
      {tag, attrs, rest}
    end
  end

  @trix_attachment_fields [:sgid, :filename, :filesize, :href, :url, :width, :height]

  defp data_trix_attachment(attrs) do
    attrs
    |> Map.take(@trix_attachment_fields)
    |> Map.put(:contentType, attrs.content_type)
    |> Jason.encode!()
  end

  @trix_attributes_fields [:caption, :presentation]

  defp data_trix_attributes(attrs) do
    attrs
    |> Map.take(@trix_attributes_fields)
    |> Jason.encode!()
  end
end
