defmodule Palapa.Repo.Migrations.CreateSearches do
  use Ecto.Migration

  def up do
    Palapa.Searches.SearchResourceTypeEnum.create_type()

    execute("CREATE EXTENSION IF NOT EXISTS unaccent;")
    # execute("CREATE EXTENSION IF NOT EXISTS pg_trgm;")

    create(table(:searches, primary_key: false)) do
      add(:organization_id, references(:organizations, type: :uuid, on_delete: :delete_all),
        null: false
      )

      add(:resource_type, :search_resource_type, null: false)
      add(:updated_at, :naive_datetime)
      add(:search_index, :tsvector)

      add(:team_id, references(:teams, type: :uuid, on_delete: :delete_all))
      add(:member_id, references(:members, type: :uuid, on_delete: :delete_all))
      add(:message_id, references(:messages, type: :uuid, on_delete: :delete_all))
      add(:document_id, references(:documents, type: :uuid, on_delete: :delete_all))
      add(:page_id, references(:pages, type: :uuid, on_delete: :delete_all))
    end

    create(index(:searches, [:team_id], unique: true))
    create(index(:searches, [:member_id], unique: true))
    create(index(:searches, [:message_id], unique: true))
    create(index(:searches, [:document_id], unique: true))
    create(index(:searches, [:page_id], unique: true))

    create(index(:searches, [:organization_id]))
    create(index(:searches, [:search_index], using: :gin))

    # --- Teams
    execute("""
    CREATE OR REPLACE FUNCTION refresh_teams_search()
    RETURNS TRIGGER LANGUAGE plpgsql
    AS $$
    DECLARE
      index_value tsvector;
    BEGIN
      index_value := setweight(to_tsvector('simple', unaccent(NEW.name)), 'A');

      INSERT INTO searches (
        organization_id,
        resource_type,
        updated_at,
        search_index,
        team_id
      )
      VALUES (
        NEW.organization_id,
        'team',
        NEW.updated_at,
        index_value,
        NEW.id
      )

      ON CONFLICT (team_id) DO UPDATE SET
        search_index = index_value,
        updated_at = NEW.updated_at
        WHERE searches.team_id = NEW.id;

      RETURN NEW;
    END $$;
    """)

    execute("DROP TRIGGER IF EXISTS refresh_teams_search_trigger ON teams;")

    execute("""
    CREATE TRIGGER refresh_teams_search_trigger
    AFTER INSERT OR UPDATE
    ON teams
    FOR EACH ROW
    EXECUTE PROCEDURE refresh_teams_search();
    """)

    # --- Members

    execute("""
    CREATE OR REPLACE FUNCTION refresh_members_search()
    RETURNS TRIGGER LANGUAGE plpgsql
    AS $$
    DECLARE
      index_value tsvector;
      member_name varchar;
      member_email varchar;
    BEGIN
      SELECT a.name, a.email INTO member_name, member_email
      FROM members as m
      JOIN accounts a ON m.account_id = a.id
      WHERE m.id = NEW.id;

      index_value := setweight(to_tsvector('simple', unaccent(member_name)), 'A') ||
        setweight(to_tsvector('simple', unaccent(member_email)), 'B') ||
        setweight(to_tsvector('simple', coalesce(unaccent(NEW.title), '')), 'B');

      INSERT INTO searches (
        organization_id,
        resource_type,
        updated_at,
        search_index,
        member_id
      )
      VALUES (
        NEW.organization_id,
        'member',
        NEW.updated_at,
        index_value,
        NEW.id
      )

      ON CONFLICT (member_id) DO UPDATE SET
        search_index = index_value,
        updated_at = NEW.updated_at
        WHERE searches.member_id = NEW.id;

      RETURN NEW;
    END $$;
    """)

    execute("DROP TRIGGER IF EXISTS refresh_members_search_trigger ON members;")

    execute("""
    CREATE TRIGGER refresh_members_search_trigger
    AFTER INSERT OR UPDATE
    ON members
    FOR EACH ROW
    EXECUTE PROCEDURE refresh_members_search();
    """)

    # --- Messages

    execute("""
    CREATE OR REPLACE FUNCTION refresh_messages_search()
    RETURNS TRIGGER LANGUAGE plpgsql
    AS $$
    DECLARE
      index_value tsvector;
    BEGIN
      index_value := setweight(to_tsvector('simple', unaccent(NEW.title)), 'A') ||
        setweight(to_tsvector('simple', coalesce(unaccent(NEW.content), '')), 'B');

      INSERT INTO searches (
        organization_id,
        resource_type,
        updated_at,
        search_index,
        message_id
      )
      VALUES (
        NEW.organization_id,
        'message',
        NEW.updated_at,
        index_value,
        NEW.id
      )

      ON CONFLICT (message_id) DO UPDATE SET
        search_index = index_value,
        updated_at = NEW.updated_at
        WHERE searches.message_id = NEW.id;

      RETURN NEW;
    END $$;
    """)

    execute("DROP TRIGGER IF EXISTS refresh_messages_search_trigger ON messages;")

    execute("""
    CREATE TRIGGER refresh_messages_search_trigger
    AFTER INSERT OR UPDATE
    ON messages
    FOR EACH ROW
    EXECUTE PROCEDURE refresh_messages_search();
    """)

    # --- Documents

    execute("""
    CREATE OR REPLACE FUNCTION refresh_documents_search()
    RETURNS TRIGGER LANGUAGE plpgsql
    AS $$
    DECLARE
      index_value tsvector;
    BEGIN
       index_value := setweight(to_tsvector('simple', unaccent(NEW.title)), 'A');

      INSERT INTO searches (
        organization_id,
        resource_type,
        updated_at,
        search_index,
        document_id
      )
      VALUES (
        NEW.organization_id,
        'document',
        NEW.updated_at,
        index_value,
        NEW.id
      )

      ON CONFLICT (document_id) DO UPDATE SET
        search_index = index_value,
        updated_at = NEW.updated_at
        WHERE searches.document_id = NEW.id;

      RETURN NEW;
    END $$;
    """)

    execute("DROP TRIGGER IF EXISTS refresh_documents_search_trigger ON documents;")

    execute("""
    CREATE TRIGGER refresh_documents_search_trigger
    AFTER INSERT OR UPDATE
    ON documents
    FOR EACH ROW
    EXECUTE PROCEDURE refresh_documents_search();
    """)

    # --- Documents pages

    execute("""
    CREATE OR REPLACE FUNCTION refresh_pages_search()
    RETURNS TRIGGER LANGUAGE plpgsql
    AS $$
    DECLARE
      index_value tsvector;
      document_organization_id uuid;
      document_title varchar;
    BEGIN
      SELECT d.organization_id, d.title INTO document_organization_id, document_title
      FROM pages p
      JOIN documents d ON p.document_id = d.id
      WHERE p.id = NEW.id;

      index_value := setweight(to_tsvector('simple', unaccent(NEW.title)), 'A') ||
        setweight(to_tsvector('simple', unaccent(document_title)), 'B') ||
        setweight(to_tsvector('simple', coalesce(unaccent(NEW.content), '')), 'C');

      INSERT INTO searches (
        organization_id,
        resource_type,
        updated_at,
        search_index,
        page_id
      )
      VALUES (
        document_organization_id,
        'page',
        NEW.updated_at,
        index_value,
        NEW.id
      )

      ON CONFLICT (page_id) DO UPDATE SET
        search_index = index_value,
        updated_at = NEW.updated_at
        WHERE searches.page_id = NEW.id;

      RETURN NEW;
    END $$;
    """)

    execute("DROP TRIGGER IF EXISTS refresh_pages_search_trigger ON pages;")

    execute("""
    CREATE TRIGGER refresh_pages_search_trigger
    AFTER INSERT OR UPDATE
    ON pages
    FOR EACH ROW
    EXECUTE PROCEDURE refresh_pages_search();
    """)
  end

  def down do
    execute("DROP TRIGGER refresh_teams_search_trigger ON teams;")
    execute("DROP FUNCTION refresh_teams_search;")

    execute("DROP TRIGGER refresh_members_search_trigger ON members;")
    execute("DROP FUNCTION refresh_members_search;")

    execute("DROP TRIGGER refresh_messages_search_trigger ON messages;")
    execute("DROP FUNCTION refresh_messages_search;")

    execute("DROP TRIGGER refresh_documents_search_trigger ON documents;")
    execute("DROP FUNCTION refresh_documents_search;")

    execute("DROP TRIGGER refresh_pages_search_trigger ON pages;")
    execute("DROP FUNCTION refresh_pages_search;")

    drop(table(:searches))
    Palapa.Searches.SearchResourceTypeEnum.drop_type()
  end
end
