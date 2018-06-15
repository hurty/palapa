defmodule Palapa.Attachments.AttachmentParser do
  @attachment_regex ~r{&quot;attachment_uuid&quot;:&quot;([\d\w-]+)&quot;}

  def extract_attachments_ids(text) when is_nil(text) do
    []
  end

  def extract_attachments_ids(text) when is_binary(text) do
    Regex.scan(@attachment_regex, text, capture: :all_but_first)
    |> List.flatten()
  end

  def diff(old_attachments_ids, new_attachments_ids)
      when is_list(old_attachments_ids) and is_list(new_attachments_ids) do
    List.myers_difference(old_attachments_ids, new_attachments_ids)
  end
end
