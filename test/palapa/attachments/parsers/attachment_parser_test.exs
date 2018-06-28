defmodule Palapa.Attachments.AttachmentParserTest do
  use ExUnit.Case

  alias Palapa.Attachments.AttachmentParser

  @input """
    <a href="/uploads/organizations/ec07fbab-c812-4c1d-a292-f83a24bea805/attachments/c97dbdfc-0283-4ed1-a384-d4a5788183a3.jpg"
      data-trix-attachment="{&quot;attachment_uuid&quot;:&quot;c97dbdfc-0283-4ed1-a384-d4a5788183a3&quot;,&quot;contentType&quot;:&quot;image/jpeg&quot;,&quot;filename&quot;:&quot;IMG_1185.jpg&quot;,&quot;filesize&quot;:2920952,&quot;height&quot;:450,&quot;href&quot;:&quot;/uploads/organizations/ec07fbab-c812-4c1d-a292-f83a24bea805/attachments/c97dbdfc-0283-4ed1-a384-d4a5788183a3.jpg&quot;,&quot;url&quot;:&quot;/uploads/organizations/ec07fbab-c812-4c1d-a292-f83a24bea805/attachments/c97dbdfc-0283-4ed1-a384-d4a5788183a3_thumb.jpg&quot;,&quot;width&quot;:600}"
      data-trix-content-type="image/jpeg">
    </a>

    <a href="/uploads/organizations/ec07fbab-c812-4c1d-a292-f83a24bea805/attachments/6b14fc08-65ac-4faa-b6a2-b17d904acec0_original.png"
    data-trix-attachment="{&quot;attachment_uuid&quot;:&quot;6b14fc08-65ac-4faa-b6a2-b17d904acec0&quot;,&quot;contentType&quot;:&quot;image/png&quot;,&quot;filename&quot;:&quot;Capture d’écran 2018-05-02 à 18.45.58.png&quot;,&quot;filesize&quot;:563023,&quot;height&quot;:819,&quot;href&quot;:&quot;/uploads/organizations/ec07fbab-c812-4c1d-a292-f83a24bea805/attachments/6b14fc08-65ac-4faa-b6a2-b17d904acec0_original.png&quot;,&quot;url&quot;:&quot;/uploads/organizations/ec07fbab-c812-4c1d-a292-f83a24bea805/attachments/6b14fc08-65ac-4faa-b6a2-b17d904acec0_thumb.png&quot;,&quot;width&quot;:465}"
    data-trix-content-type="image/png"><figure class="attachment attachment--preview attachment--png">
    </a>
  """

  test "finds attachments ids in the content" do
    assert ["c97dbdfc-0283-4ed1-a384-d4a5788183a3", "6b14fc08-65ac-4faa-b6a2-b17d904acec0"] ==
             AttachmentParser.extract_attachments_ids(@input)
  end

  test "no attachments to create nor delete when there is nothing to attach" do
    assert [] == AttachmentParser.diff([], [])
  end

  test "no attachments to create nor delete when attachments are still the same" do
    assert [eq: ["a1"]] == AttachmentParser.diff(["a1"], ["a1"])
  end

  test "finds attachments ids to create or delete" do
    assert [del: ["a1"], eq: ["a2"], ins: ["a3"]] ==
             AttachmentParser.diff(["a1", "a2"], ["a2", "a3"])
  end
end
