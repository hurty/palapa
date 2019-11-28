defmodule Palapa.RichText.Content do
  defstruct html: nil,
            tree: [],
            embedded_attachments: [],
            attachments: [],
            attachments_resolved: false
end

defimpl String.Chars, for: Palapa.RichText.Content do
  def to_string(content) do
    Palapa.RichText.to_html(content)
  end
end

defimpl Jason.Encoder, for: Palapa.RichText.Content do
  def encode(content, opts) do
    Palapa.RichText.to_html(content)
    |> Jason.Encode.string(opts)
  end
end
