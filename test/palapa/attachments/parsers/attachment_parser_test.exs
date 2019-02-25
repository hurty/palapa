defmodule Palapa.Attachments.AttachmentParserTest do
  use ExUnit.Case

  alias Palapa.Attachments.AttachmentParser

  @input """
  <div>Test attachment</div><div class="attachment-gallery attachment-gallery--2">
    <figure data-trix-attachment="{&quot;attachment_sid&quot;:&quot;SFMyNTY.g3QAAAACZAAEZGF0YW0AAAAkNmFjNDJmOGYtMmUzMy00NDhhLWE1MTItZmI3ODgwYzQ1ZmQxZAAGc2lnbmVkbgYAfDihJWkB.mwEFvAcx3GJp7XKUd0ktXKGexwG3nFWv368ujlpLbOM&quot;,&quot;contentType&quot;:&quot;image/jpeg&quot;,&quot;filename&quot;:&quot;erlich.jpg&quot;,&quot;filesize&quot;:120786,&quot;height&quot;:512,&quot;href&quot;:&quot;https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/6ac42f8f-2e33-448a-a512-fb7880c45fd1/original/erlich.jpg&quot;,&quot;url&quot;:&quot;https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/6ac42f8f-2e33-448a-a512-fb7880c45fd1/thumb/erlich.jpg&quot;,&quot;width&quot;:512}" data-trix-content-type="image/jpeg" data-trix-attributes="{&quot;presentation&quot;:&quot;gallery&quot;}" class="attachment attachment--preview attachment--jpg">
    <a href="https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/6ac42f8f-2e33-448a-a512-fb7880c45fd1/original/erlich.jpg"><img src="https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/6ac42f8f-2e33-448a-a512-fb7880c45fd1/thumb/erlich.jpg" width="512" height="512"><figcaption class="attachment__caption"><span class="attachment__name">erlich.jpg</span> <span class="attachment__size">117.96 KB</span></figcaption></a></figure>

    <figure data-trix-attachment="{&quot;attachment_sid&quot;:&quot;SFMyNTY.g3QAAAACZAAEZGF0YW0AAAAkNjBlZDk0MzctYzdmZi00OTc5LWI3YmUtYzEyYTdkM2IxNTZiZAAGc2lnbmVkbgYA-jihJWkB.-sNlpoN525f8Acjs8Nvf_Di6wAhmE7uKH-BeCTM4g6o&quot;,&quot;contentType&quot;:&quot;image/jpeg&quot;,&quot;filename&quot;:&quot;gilfoyle.jpg&quot;,&quot;filesize&quot;:109937,&quot;height&quot;:512,&quot;href&quot;:&quot;https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/60ed9437-c7ff-4979-b7be-c12a7d3b156b/original/gilfoyle.jpg&quot;,&quot;url&quot;:&quot;https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/60ed9437-c7ff-4979-b7be-c12a7d3b156b/thumb/gilfoyle.jpg&quot;,&quot;width&quot;:512}" data-trix-content-type="image/jpeg" data-trix-attributes="{&quot;presentation&quot;:&quot;gallery&quot;}" class="attachment attachment--preview attachment--jpg">
    <a href="https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/60ed9437-c7ff-4979-b7be-c12a7d3b156b/original/gilfoyle.jpg"><img src="https://localhost:4000/org/bc9333ad-7988-4482-a49f-f25b64361c82/attachments/60ed9437-c7ff-4979-b7be-c12a7d3b156b/thumb/gilfoyle.jpg" width="512" height="512"><figcaption class="attachment__caption"><span class="attachment__name">gilfoyle.jpg</span> <span class="attachment__size">107.36 KB</span></figcaption></a></figure>
  </div>
  """

  test "finds attachments signed ids in the content" do
    assert [
             "SFMyNTY.g3QAAAACZAAEZGF0YW0AAAAkNmFjNDJmOGYtMmUzMy00NDhhLWE1MTItZmI3ODgwYzQ1ZmQxZAAGc2lnbmVkbgYAfDihJWkB.mwEFvAcx3GJp7XKUd0ktXKGexwG3nFWv368ujlpLbOM",
             "SFMyNTY.g3QAAAACZAAEZGF0YW0AAAAkNjBlZDk0MzctYzdmZi00OTc5LWI3YmUtYzEyYTdkM2IxNTZiZAAGc2lnbmVkbgYA-jihJWkB.-sNlpoN525f8Acjs8Nvf_Di6wAhmE7uKH-BeCTM4g6o"
           ] == AttachmentParser.extract_attachments_signed_ids(@input)
  end
end
