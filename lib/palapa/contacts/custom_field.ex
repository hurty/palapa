defmodule Palapa.Contacts.CustomField do
  use Palapa.Schema

  embedded_schema do
    field :label, :string
    field :value, :string
  end

  def changeset(custom_field, attrs) do
    custom_field
    |> cast(attrs, [:label, :value])
    |> validate_required([:label, :value])
  end
end
