defmodule Palapa.Attachments.AttachmentParser do
  @attachment_regex ~r{&quot;attachment_sid&quot;:&quot;([\w.-]+)&quot;}

  def extract_attachments_signed_ids(text) when is_nil(text) do
    []
  end

  def extract_attachments_signed_ids(text) when is_binary(text) do
    Regex.scan(@attachment_regex, text, capture: :all_but_first)
    |> List.flatten()
  end
end
