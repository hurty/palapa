defmodule Palapa.RichText.ConversionToHTML do
  alias Palapa.RichText.{Tree, TrixScrubber}
  alias PalapaWeb.RichTextView

  @embedded_attachment_tag "embedded-attachment"

  def convert(content) do
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
      attachment_template =
        Phoenix.View.render_to_iodata(RichTextView, "attachment.html", attrs)
        |> Tree.parse()

      {tag, attrs, [attachment_template]}
    else
      {tag, attrs, rest}
    end
  end

  defp to_raw_html(content) do
    Floki.raw_html(content.tree)
  end

  defp sanitize(html) do
    HtmlSanitizeEx.Scrubber.scrub(html, TrixScrubber)
  end
end
