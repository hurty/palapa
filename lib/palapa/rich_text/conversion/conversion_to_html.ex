defmodule Palapa.RichText.ConversionToHTML do
  alias Palapa.RichText.{Content, EmbeddedAttachment}
  alias Palapa.RichText.RichTextView

  @embedded_attachment_tag "embedded-attachment"

  def convert(%Content{} = content) do
    content
    |> render_attachments()
  end

  defp render_attachments(content) do
    tree = Floki.traverse_and_update(content.tree, &render_attachment(content, &1))
    Map.put(content, :tree, tree)
  end

  defp render_attachment(content, {tag, attrs, rest}) do
    if tag == @embedded_attachment_tag do
      attrs =
        if content.attachments_resolved do
          attrs
        else
          Enum.into(attrs, %{}, fn {k, v} -> {String.to_atom(k), v} end)
        end

      embedded_attachment_nodes =
        struct(EmbeddedAttachment, parse_values(attrs))
        |> to_attachment_template
        |> Floki.parse()

      {tag, attrs, [embedded_attachment_nodes]}
    else
      {tag, attrs, rest}
    end
  end

  def parse_values(attrs) do
    parse = fn value ->
      IO.inspect(value, label: "value")

      if value do
        case Integer.parse(value) do
          {parsed_value, _rest} -> parsed_value
          :error -> nil
        end
      else
        nil
      end
    end

    attrs
    |> Map.put(:width, parse.(attrs[:width]))
    |> Map.put(:height, parse.(attrs[:height]))
    |> Map.put(:filesize, parse.(attrs[:filesize]))
  end

  defp to_attachment_template(embedded_attachment) do
    template_filename =
      cond do
        EmbeddedAttachment.has_associated_attachment?(embedded_attachment) ->
          "attachment.html"

        EmbeddedAttachment.custom?(embedded_attachment) ->
          "attachment_custom.html"

        EmbeddedAttachment.remote_image?(embedded_attachment) ->
          "attachment_remote_image.html"

        true ->
          "attachment_missing.html"
      end

    Phoenix.View.render_to_iodata(RichTextView, template_filename,
      embedded_attachment: embedded_attachment
    )
  end
end
