require Logger

defmodule Palapa.RichText do
  alias Palapa.RichText.{Attachments, Content}

  def from_trix(rich_text) do
    parse_from_trix(rich_text)
  end

  def to_trix(%Content{} = content) do
    Floki.raw_html(content.nodes)
  end

  def to_html(%Content{} = content) do
    Floki.raw_html(content.nodes)
  end

  defp parse_from_trix(rich_text) do
    nodes = Floki.parse(rich_text)

    embedded_attachments = Attachments.find_attachments(nodes)
    nodes = Attachments.transform_embedded_attachments(nodes)

    %Content{
      embedded_attachments: embedded_attachments,
      nodes: nodes
    }
  end
end
