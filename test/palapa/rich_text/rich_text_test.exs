defmodule Palapa.RichTextTest do
  use Palapa.DataCase

  alias Palapa.RichText
  alias Palapa.Attachments.Attachment
  alias Palapa.Organizations.Organization

  @attachment_id 123
  @attachment_sgid Palapa.Access.generate_signed_id(@attachment_id)
  @trix_formatted_attachment """
  <figure data-trix-attachment="{&quot;sgid&quot;:&quot;#{@attachment_sgid}&quot;,&quot;contentType&quot;:&quot;image/png&quot;,&quot;filename&quot;:&quot;hello.png&quot;,&quot;filesize&quot;:331291,&quot;height&quot;:525,&quot;url&quot;:&quot;https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/thumb/hello.png&quot;,&quot;width&quot;:436}"
  data-trix-content-type="image/png"
  data-trix-attributes="{&quot;caption&quot;:&quot;Hello Caption&quot;,&quot;presentation&quot;:&quot;gallery&quot;}"
  class="attachment attachment--preview attachment--png">
    <a href="https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/original/hello.png">
      <img src="https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/thumb/hello.png" width="436" height="525">
      <figcaption class="attachment__caption attachment__caption--edited">Hello Caption</figcaption>
    </a>
  </figure>
  """

  test "extracts attachment from trix html" do
    html = "<div><h1>A nice document</h1>#{@trix_formatted_attachment}</div>"

    content = RichText.from_trix(html)
    assert 1 == length(content.embedded_attachments)

    embedded_attachment = Enum.at(content.embedded_attachments, 0)

    assert @attachment_sgid == embedded_attachment.sgid
    assert @attachment_id == embedded_attachment.id
    refute embedded_attachment.missing

    assert "hello.png" == embedded_attachment.filename
    assert "image/png" == embedded_attachment.content_type
    assert "331291" == embedded_attachment.filesize
    assert "525" == embedded_attachment.height
    assert "436" == embedded_attachment.width
    assert is_nil(embedded_attachment.previewable)

    assert "Hello Caption" == embedded_attachment.caption
    assert "gallery" == embedded_attachment.presentation
  end

  test "extracts multiple attachments from trix html" do
    html = """
    <div>
      <h1>A nice document</h1>
      <div>#{@trix_formatted_attachment}</div>
      <div>#{@trix_formatted_attachment}</div>
    </div>
    <p>Some stuff</p>
    """

    content = RichText.from_trix(html)
    assert 2 == length(content.embedded_attachments)
  end

  test "to html" do
    trix_html = "<div><h1>A nice document</h1>#{@trix_formatted_attachment}</div>"

    html_content =
      trix_html
      |> RichText.from_trix()
      |> RichText.to_html()

    expected =
      "<div><h1>A nice document</h1><embedded-attachment><figure class=\"attachment attachment--preview\"><a href=\"https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/thumb/hello.png\"><img src=\"https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/thumb/hello.png\" width=\"436\" height=\"525\" /></a><figcaption>Hello Caption</figcaption><figcaption>331291</figcaption></figure></embedded-attachment></div>"

    assert expected == html_content
  end

  defp insert_attachment() do
    %Attachment{
      filename: "palapa.jpg",
      content_type: "image/jpg",
      organization: %Organization{name: "Palapa"}
    }
    |> Palapa.Repo.insert()
  end
end
