defmodule Palapa.Contacts.Contact do
  use Palapa.Schema

  alias Palapa.Organizations.Organization
  alias Palapa.Contacts.{ContactComment}

  schema "contacts" do
    timestamps()
    belongs_to(:organization, Organization)
    belongs_to(:company, __MODULE__)
    has_many(:comments, ContactComment)

    field :is_company, :boolean
    field :first_name, :string
    field :last_name, :string
    field :title, :string
    field :email, :string
    field :phone, :string
    field :work, :string
    field :chat, :string
    field :address_line1, :string
    field :address_line2, :string
    field :address_postal_code, :string
    field :address_city, :string
    field :address_country, :string
    field :additional_info, :string
  end

  @doc false
  def changeset(contact, attrs \\ %{}) do
    contact
    |> cast(attrs, [
      :is_company,
      :first_name,
      :last_name,
      :email,
      :phone,
      :work,
      :chat,
      :address_line1,
      :address_line2,
      :address_postal_code,
      :address_city,
      :address_country,
      :additional_info,
      :company_id,
      :title
    ])
    |> validate_name
  end

  defp validate_name(changeset) do
    first_name = get_field(changeset, :first_name)
    last_name = get_field(changeset, :last_name)

    if((first_name == "" || is_nil(first_name)) && (last_name == "" || is_nil(last_name))) do
      add_error(changeset, :first_name, "Give at least a first or last name")
    else
      changeset
    end
  end
end
