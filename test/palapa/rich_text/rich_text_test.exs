defmodule Palapa.RichTextTest do
  use Palapa.DataCase

  import Palapa.RichText

  test "simple HTML back and forth from trix to trix" do
    html = "<div>a<br/></div>"
    content = from_trix(html)
    assert html == to_trix(content)
  end
end
