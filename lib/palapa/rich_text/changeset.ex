defmodule Palapa.RichText.Changeset do
  alias Palapa.RichText
  import Ecto.Changeset

  def put_rich_text(changeset, rich_text_field, attachments_assoc \\ nil) do
    rich_text = get_field(changeset, rich_text_field)

    if rich_text do
      content = RichText.from_trix(rich_text)

      changeset
      |> do_put_rich_text(rich_text_field, content)
      |> do_put_rich_text_attachments(attachments_assoc, content)
    else
      changeset
    end
  end

  def do_put_rich_text(changeset, rich_text_field, content) do
    changeset
    |> force_change(rich_text_field, RichText.to_html(content))
  end

  def do_put_rich_text_attachments(changeset, nil, _content) do
    changeset
  end

  def do_put_rich_text_attachments(changeset, attachments_assoc, content) do
    changeset
    |> put_assoc(attachments_assoc, content.attachments)
  end
end
