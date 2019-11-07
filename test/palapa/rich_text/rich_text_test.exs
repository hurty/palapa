defmodule Palapa.RichTextTest do
  use Palapa.DataCase

  alias Palapa.RichText
  alias Palapa.RichText.EmbeddedAttachment
  alias Palapa.Attachments.Attachment
  alias Palapa.Organizations.Organization

  @trix_remote_image_attachment """
  <figure data-trix-attachment="{&quot;contentType&quot;:&quot;image&quot;,&quot;height&quot;:458,&quot;url&quot;:&quot;https://img.lemde.fr/2019/03/18/0/0/2883/1918/688/0/60/0/05fe634_5464725-01-06.jpg&quot;,&quot;width&quot;:688}"
  data-trix-content-type="image"
  data-trix-attributes="{&quot;caption&quot;:&quot;Hello Caption&quot;}"
  class="attachment attachment--preview">
    <img src="https://img.lemde.fr/2019/03/18/0/0/2883/1918/688/0/60/0/05fe634_5464725-01-06.jpg" width="688" height="458">
    <figcaption class="attachment__caption attachment__caption--edited">Hello Caption</figcaption>
  </figure>
  """

  @trix_custom_attachment """
  <figure data-trix-attachment="{&quot;content&quot;:&quot;<hr>&quot;,&quot;contentType&quot;:&quot;application/vnd.richtext.horizontal-rule.html&quot;}"
    data-trix-content-type="application/vnd.richtext.horizontal-rule.html" class="attachment attachment--content"><hr>
    <figcaption class="attachment__caption"></figcaption>
  </figure>
  """

  defp insert_image_attachment() do
    %Attachment{
      filename: "palapa.jpg",
      content_type: "image/jpg",
      organization: %Organization{name: "Palapa"}
    }
    |> Palapa.Repo.insert!()
  end

  defp insert_pdf_attachment() do
    %Attachment{
      filename: "palapa.pdf",
      content_type: "application/pdf",
      organization: %Organization{name: "Palapa"}
    }
    |> Palapa.Repo.insert!()
  end

  defp image_attachment() do
    attachment = insert_image_attachment()
    attachment_sgid = Palapa.Access.generate_signed_id(attachment.id)

    html_attachment = """
    <figure data-trix-attachment="{&quot;sgid&quot;:&quot;#{attachment_sgid}&quot;,&quot;contentType&quot;:&quot;image/png&quot;,&quot;filename&quot;:&quot;hello.png&quot;,&quot;filesize&quot;:331291,&quot;height&quot;:525,&quot;url&quot;:&quot;https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/thumb/hello.png&quot;,&quot;width&quot;:436}"
    data-trix-content-type="image/png"
    data-trix-attributes="{&quot;caption&quot;:&quot;Hello Caption&quot;,&quot;presentation&quot;:&quot;gallery&quot;}"
    class="attachment attachment--preview attachment--png">
      <a href="https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/original/hello.png">
        <img src="https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fccf08e5-1101-49e9-8564-5162b001adde/thumb/hello.png" width="436" height="525">
        <figcaption class="attachment__caption attachment__caption--edited">Hello Caption</figcaption>
      </a>
    </figure>
    """

    {attachment, attachment_sgid, html_attachment}
  end

  defp pdf_attachment() do
    attachment = insert_pdf_attachment()
    attachment_sgid = Palapa.Access.generate_signed_id(attachment.id)

    html_attachment = """
    <figure data-trix-attachment="{&quot;contentType&quot;:&quot;application/pdf&quot;,&quot;filename&quot;:&quot;cerfa.pdf&quot;,&quot;filesize&quot;:415460,&quot;href&quot;:&quot;https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/9424cef9-831e-473b-a084-d138d14999b0/original/cerfa.pdf&quot;,&quot;sgid&quot;:&quot;#{
      attachment_sgid
    }&quot;,&quot;url&quot;:&quot;https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/9424cef9-831e-473b-a084-d138d14999b0/thumb/cerfa.pdf&quot;}"
    data-trix-content-type="application/pdf"
    class="attachment attachment--file attachment--pdf">
      <a href="https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/9424cef9-831e-473b-a084-d138d14999b0/original/cerfa.pdf">
      <figcaption class="attachment__caption"><span class="attachment__name">cerfa.pdf</span> <span class="attachment__size">405.72 KB</span></figcaption></a>
    </figure>
    """

    {attachment, attachment_sgid, html_attachment}
  end

  test "extracts an image attachment from trix" do
    {_attachment, attachment_sgid, html_attachment} = image_attachment()
    html = "<div><h1>A nice document</h1>#{html_attachment}</div>"

    content = RichText.from_trix(html)
    assert 1 == length(content.embedded_attachments)

    embedded_attachment = Enum.at(content.embedded_attachments, 0)

    assert attachment_sgid == embedded_attachment.sgid

    assert "hello.png" == embedded_attachment.filename
    assert "image/png" == embedded_attachment.content_type
    assert "331291" == embedded_attachment.filesize
    assert "525" == embedded_attachment.height
    assert "436" == embedded_attachment.width

    assert "Hello Caption" == embedded_attachment.caption
    assert "gallery" == embedded_attachment.presentation

    assert EmbeddedAttachment.has_associated_attachment?(embedded_attachment)
    assert EmbeddedAttachment.image?(embedded_attachment)
    refute EmbeddedAttachment.remote_image?(embedded_attachment)
    refute EmbeddedAttachment.custom?(embedded_attachment)
  end

  test "extracts a remote image attachment from trix" do
    html = "<div><h1>A nice document</h1>#{@trix_remote_image_attachment}</div>"

    content = RichText.from_trix(html)
    assert 1 == length(content.embedded_attachments)

    embedded_attachment = Enum.at(content.embedded_attachments, 0)

    refute embedded_attachment.sgid
    refute embedded_attachment.attachment
    refute embedded_attachment.filename
    refute embedded_attachment.filesize
    refute embedded_attachment.presentation

    assert "image" == embedded_attachment.content_type
    assert "458" == embedded_attachment.height
    assert "688" == embedded_attachment.width
    assert "Hello Caption" == embedded_attachment.caption

    refute EmbeddedAttachment.has_associated_attachment?(embedded_attachment)
    assert EmbeddedAttachment.image?(embedded_attachment)
    assert EmbeddedAttachment.remote_image?(embedded_attachment)
    refute EmbeddedAttachment.custom?(embedded_attachment)
  end

  test "extracts a non-previewable file attachment from trix" do
    {_attachment, attachment_sgid, html_attachment} = pdf_attachment()
    html = "<div><h1>A nice document</h1>#{html_attachment}</div>"

    content = RichText.from_trix(html)
    assert 1 == length(content.embedded_attachments)

    embedded_attachment = Enum.at(content.embedded_attachments, 0)

    assert attachment_sgid == embedded_attachment.sgid

    assert "cerfa.pdf" == embedded_attachment.filename
    assert "application/pdf" == embedded_attachment.content_type
    assert "415460" == embedded_attachment.filesize

    refute embedded_attachment.height
    refute embedded_attachment.width
    refute embedded_attachment.caption
    refute embedded_attachment.presentation

    assert EmbeddedAttachment.has_associated_attachment?(embedded_attachment)
    refute EmbeddedAttachment.image?(embedded_attachment)
    refute EmbeddedAttachment.remote_image?(embedded_attachment)
    refute EmbeddedAttachment.custom?(embedded_attachment)
  end

  test "extracts a custom HTML attachment from trix" do
    html = "<div><h1>A nice document</h1>#{@trix_custom_attachment}</div>"

    content = RichText.from_trix(html)
    assert 1 == length(content.embedded_attachments)

    embedded_attachment = Enum.at(content.embedded_attachments, 0)

    assert "application/vnd.richtext.horizontal-rule.html" == embedded_attachment.content_type

    refute embedded_attachment.sgid
    refute embedded_attachment.attachment
    refute embedded_attachment.filename
    refute embedded_attachment.filesize
    refute embedded_attachment.presentation
    refute embedded_attachment.caption
    refute embedded_attachment.width
    refute embedded_attachment.height

    refute EmbeddedAttachment.has_associated_attachment?(embedded_attachment)
    refute EmbeddedAttachment.image?(embedded_attachment)
    refute EmbeddedAttachment.remote_image?(embedded_attachment)
    assert EmbeddedAttachment.custom?(embedded_attachment)
  end

  test "extracts multiple attachments from trix html" do
    {_attachment, _attachment_sgid, html_attachment} = image_attachment()

    html = """
    <div>
      <h1>A nice document</h1>
      <div>#{html_attachment}</div>
      <div>#{html_attachment}</div>
    </div>
    <p>Some stuff</p>
    """

    content = RichText.from_trix(html)
    assert 2 == length(content.embedded_attachments)
  end

  test "turns a canonical attachment into a trix-formatted attachment" do
    canonical_attachment =
      """
      <embedded-attachment
        content_type="image/jpeg"
        filename="29072014-P7292367.jpg"
        filesize="1394841" height="3024"
        href="/uploads/organizations/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fdfc67e9-a840-461a-a30a-17c751f79951/original.jpg"
        presentation="gallery"
        sgid="SFMyNTY.g3QAAAACZAAEZGF0YW0AAAAkZmRmYzY3ZTktYTg0MC00NjFhLWEzMGEtMTdjNzUxZjc5OTUxZAAGc2lnbmVkbgYAQCh_tWkB.Pd9ezyReUUrPf4wwP2LPR2EHoc-T7xXN2oQAn-Qn1Tk" url="/uploads/organizations/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fdfc67e9-a840-461a-a30a-17c751f79951/original.jpg"
        width="4032">
      </embedded-attachment>
      """
      |> RichText.load()

    expected_html =
      "<figure data-trix-attachment='{\"contentType\":\"image/jpeg\",\"filename\":\"29072014-P7292367.jpg\",\"filesize\":\"1394841\",\"height\":\"3024\",\"href\":\"/uploads/organizations/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fdfc67e9-a840-461a-a30a-17c751f79951/original.jpg\",\"sgid\":\"SFMyNTY.g3QAAAACZAAEZGF0YW0AAAAkZmRmYzY3ZTktYTg0MC00NjFhLWEzMGEtMTdjNzUxZjc5OTUxZAAGc2lnbmVkbgYAQCh_tWkB.Pd9ezyReUUrPf4wwP2LPR2EHoc-T7xXN2oQAn-Qn1Tk\",\"url\":\"/uploads/organizations/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/fdfc67e9-a840-461a-a30a-17c751f79951/original.jpg\",\"width\":\"4032\"}' data-trix-content-type=\"image/jpeg\" data-trix-attributes='{\"presentation\":\"gallery\"}'></figure>"

    assert expected_html == RichText.to_trix(canonical_attachment)
  end
end
