defmodule Palapa.RichText do
  alias Palapa.RichText.{
    Content,
    ConversionFromTrix,
    ConversionToTrix,
    ConversionToHTML,
    Tree,
    TrixScrubber
  }

  @doc """
  Trix formats attachments in a <figure> element and stores attachment metadata in
  multiple JSON encoded data attributes:

    - data-trix-attachments
    - data-trix-attributes
    - data-trix-content-type

  <figure
    data-trix-attachment="{&quot;contentType&quot;:&quot;application/pdf&quot;,&quot;filename&quot;:&quot;Mind-is-not-consciousness.pdf&quot;,&quot;filesize&quot;:19491,&quot;sgid&quot;:&quot;BAh7CEkiCGdpZAY6BkVUSSI2Z2lkOi8vdGVzdHJhaWxzL0FjdGl2ZVN0b3JhZ2U6OkJsb2IvMTE_ZXhwaXJlc19pbgY7AFRJIgxwdXJwb3NlBjsAVEkiD2F0dGFjaGFibGUGOwBUSSIPZXhwaXJlc19hdAY7AFQw--c6552e94ccb5b9fa52dbc5bde5cfd548db53d917&quot;,&quot;url&quot;:&quot;http://localhost:3000/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBFQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--9a1753d5546bd5012157ca31c45242eae166e344/Mind-is-not-consciousness.pdf&quot;}"
    data-trix-content-type="application/pdf"
    class="attachment attachment--file attachment--pdf">

    <figcaption class="attachment__caption">
      <span class="attachment__name">Mind-is-not-consciousness.pdf</span>
      <span class=\"attachment__size\">19.03 KB</span>
    </figcaption>
  </figure>

  We want to transform this attachment figure into a <embedded-attachment> element and identify
  associated attachments records:

  <embedded-attachment
    sgid="BAh7CEkiCGdpZAY6BkVUSSI2Z2lkOi8vdGVzdHJhaWxzL0FjdGl2ZVN0b3JhZ2U6OkJsb2IvMTA_ZXhwaXJlc19pbgY7AFRJIgxwdXJwb3NlBjsAVEkiD2F0dGFjaGFibGUGOwBUSSIPZXhwaXJlc19hdAY7AFQw--34f22939c406e0007a75a850037cf0f6dc25f5d8"
    content-type="application/pdf"
    url="http://localhost:3000/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBEdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--34c54b0506ecef1c0900cd651bb3fbda5271ea3b/Mind-is-not-consciousness.pdf"
    filename="Mind-is-not-consciousness.pdf"
    filesize="19491">
  </embedded-attachment>
  """

  #####

  def load(html_string) do
    tree = Tree.parse(html_string)
    %Content{tree: tree}
  end

  @doc "Transforms a Trix-formatted text into a canonical struct"
  def from_trix(html_string) do
    html_string
    |> sanitize()
    |> load()
    |> ConversionFromTrix.convert()
  end

  @doc "Transforms a canonical text into a well formatted HTML"
  def to_formatted_html(content) when is_nil(content), do: nil

  def to_formatted_html(%Content{} = content) do
    content
    |> ConversionToHTML.convert()
    |> to_html()
  end

  @doc "Transforms a canonical text into a Trix-formatted HTML string"
  def to_trix(content) when is_nil(content), do: nil

  def to_trix(%Content{} = content) do
    content
    |> ConversionToTrix.convert()
    |> to_html()
  end

  def to_html(%Content{} = content) do
    Floki.raw_html(content.tree)
  end

  defp sanitize(html_string) do
    HtmlSanitizeEx.Scrubber.scrub(html_string, TrixScrubber)
  end
end

defimpl String.Chars, for: Palapa.RichText.Content do
  def to_string(content) do
    Palapa.RichText.to_html(content)
  end
end
