defmodule Palapa.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add(:organization_id, references(:organizations, on_delete: :delete_all), null: false)

      add(:is_company, :boolean)

      add(:first_name, :string)
      add(:last_name, :string)

      add(:company_id, references(:contacts, on_delete: :nilify_all))
      add(:title, :string)

      add(:email, :string)
      add(:phone, :string)
      add(:work, :string)
      add(:chat, :string)

      add(:address_line1, :string)
      add(:address_line2, :string)
      add(:address_postal_code, :string)
      add(:address_city, :string)
      add(:address_country, :string)

      add(:additional_info, :text)
      timestamps()
    end

    create(index(:contacts, :organization_id))
    create(index(:contacts, :company_id))

    alter(table(:events)) do
      add(:contact_id, references(:contacts, on_delete: :delete_all))
    end

    create(index(:events, :contact_id))
  end
end
