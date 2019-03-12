defmodule Palapa.RichTextTest do
  use Palapa.DataCase
  import Palapa.RichText

  alias Palapa.Attachments.Attachment
  alias Palapa.Organizations.Organization

  test "simple HTML back and forth from trix to trix" do
    html = "<div>a<br/></div>"
    content = from_trix(html)
    assert html == to_trix(content)
  end

  test "extract attachment from rich text" do
    {:ok, attachment} = insert_attachment()
    sgid = Palapa.Access.generate_signed_id(attachment.id)

    html = """
    <h1>Hello World</h1>
    <div>This is a test<br>
      <figure data-trix-attachment="{&quot;sgid&quot;:&quot;#{sgid}&quot;,&quot;contentType&quot;:&quot;image/png&quot;,&quot;filename&quot;:&quot;hello.png&quot;,&quot;filesize&quot;:331291,&quot;height&quot;:525,&quot;href&quot;:&quot;https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/original/hello.png&quot;,&quot;url&quot;:&quot;https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/thumb/hello.png&quot;,&quot;width&quot;:436}"
      data-trix-content-type="image/png"
      data-trix-attributes="{&quot;caption&quot;:&quot;Hello Caption&quot;,&quot;presentation&quot;:&quot;gallery&quot;}"
      class="attachment attachment--preview attachment--png">
        <a href="https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/original/hello.png">
          <img src="https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/thumb/hello.png" width="436" height="525">
          <figcaption class="attachment__caption attachment__caption--edited">Hello Caption</figcaption>
        </a>
      </figure>
    </div>
    """

    content = from_trix(html)
    assert 1 == length(content.embedded_attachments)

    embedded_attachment = Enum.at(content.embedded_attachments, 0)

    assert attachment.id == embedded_attachment.id
    refute embedded_attachment.missing

    assert "hello.png" == embedded_attachment.filename
    assert "image/png" == embedded_attachment.content_type
    assert 331_291 == embedded_attachment.filesize
    assert 525 == embedded_attachment.height
    assert 436 == embedded_attachment.width
    assert is_nil(embedded_attachment.previewable)

    assert "Hello Caption" == embedded_attachment.caption
    assert "gallery" == embedded_attachment.presentation
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
