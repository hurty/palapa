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

    alter table(:searches) do
      add(:contact_id, references(:contacts, type: :uuid, on_delete: :delete_all))
    end

    create(index(:searches, [:contact_id], unique: true))

    execute("""
    CREATE OR REPLACE FUNCTION refresh_contacts_search()
    RETURNS TRIGGER LANGUAGE plpgsql
    AS $$
    DECLARE
      index_value tsvector;
    BEGIN
      index_value := setweight(to_tsvector('simple', coalesce(unaccent(NEW.first_name), '')), 'A') ||
        setweight(to_tsvector('simple', coalesce(unaccent(NEW.last_name), '')), 'A');

      INSERT INTO searches (
        organization_id,
        resource_type,
        updated_at,
        search_index,
        contact_id
      )
      VALUES (
        NEW.organization_id,
        'contact',
        NEW.updated_at,
        index_value,
        NEW.id
      )

      ON CONFLICT (contact_id) DO UPDATE SET
        search_index = index_value,
        updated_at = NEW.updated_at
        WHERE searches.contact_id = NEW.id;

      RETURN NEW;
    END $$;
    """)

    execute("DROP TRIGGER IF EXISTS refresh_contacts_search_trigger ON contacts;")

    execute("""
    CREATE TRIGGER refresh_contacts_search_trigger
    AFTER INSERT OR UPDATE
    ON contacts
    FOR EACH ROW
    EXECUTE PROCEDURE refresh_contacts_search();
    """)
  end
end
