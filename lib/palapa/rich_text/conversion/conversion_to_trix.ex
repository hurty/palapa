defmodule Palapa.RichText.ConversionToTrix do
  alias Palapa.RichText.{Content, EmbeddedAttachment, Tree}

  @embedded_attachment_tag "embedded-attachment"

  def convert(%Content{} = content) do
    content
  end

  def convert(%Content{} = content) do
    content
    |> render_attachments()
  end

  defp render_attachments(content) do
    tree = Tree.map(content.tree, &render_attachment(&1))
    Map.put(content, :tree, tree)
  end

  defp render_attachment({tag, attrs, rest}) do
    if tag == @embedded_attachment_tag do
      attrs = Enum.into(attrs, %{}, fn {k, v} -> {String.to_atom(k), v} end)

      embedded_attachment_nodes =
        attrs
        |> IO.inspect()

      # struct(EmbeddedAttachment, attrs)
      # |> Tree.parse()

      {tag, attrs, [embedded_attachment_nodes]}
    else
      {tag, attrs, rest}
    end
  end

  defp data_trix_attachment_attribute(attrs) do
  end
end
