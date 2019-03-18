defmodule Palapa.RichText.ConversionToHTML do
  alias Palapa.RichText.{Content, EmbeddedAttachment, Tree, TrixScrubber}
  alias PalapaWeb.RichTextView

  @embedded_attachment_tag "embedded-attachment"

  def convert(%Content{} = content) do
    content
    |> render_attachments()
    |> to_raw_html()
    |> sanitize()
  end

  defp render_attachments(content) do
    tree = Tree.map(content.tree, &render_attachment(&1))
    Map.put(content, :tree, tree)
  end

  defp render_attachment({tag, attrs, rest}) do
    if tag == @embedded_attachment_tag do
      embedded_attachment_nodes =
        struct(EmbeddedAttachment, attrs)
        # locate sgid () à faire
        |> to_attachment_template
        |> Tree.parse()

      {tag, attrs, [embedded_attachment_nodes]}
    else
      {tag, attrs, rest}
    end
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

    Phoenix.View.render_to_iodata(RichTextView, template_filename, attachment: embedded_attachment)
  end

  defp to_raw_html(content) do
    Floki.raw_html(content.tree)
  end

  defp sanitize(html) do
    HtmlSanitizeEx.Scrubber.scrub(html, TrixScrubber)
  end
end
