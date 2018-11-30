defmodule Palapa.Repo.Migrations.CreateSearches do
  use Ecto.Migration

  def up do
    Palapa.Searches.SearchResourceTypeEnum.create_type()

    execute("CREATE EXTENSION IF NOT EXISTS unaccent;")
    execute("CREATE EXTENSION IF NOT EXISTS pg_trgm;")

    create(table(:searches, primary_key: false)) do
      add(:organization_id, references(:organizations, type: :uuid, on_delete: :delete_all),
        null: false
      )

      add(:resource_type, :search_resource_type, null: false)
      add(:updated_at, :naive_datetime)
      add(:search_index, :tsvector)
      add(:title, :string)

      add(:team_id, references(:teams, type: :uuid, on_delete: :delete_all))
      add(:message_id, references(:messages, type: :uuid, on_delete: :delete_all))
    end

    create(index(:searches, [:team_id], unique: true))
    create(index(:searches, [:message_id], unique: true))

    create(index(:searches, [:organization_id]))
    create(index(:searches, [:search_index], using: :gin))

    # --- Teams
    execute("""
    CREATE OR REPLACE FUNCTION refresh_teams_search()
    RETURNS TRIGGER LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO searches (organization_id, resource_type, updated_at, search_index, title, team_id)
      VALUES (NEW.organization_id, 'team', NEW.updated_at, setweight(to_tsvector('simple', unaccent(NEW.name)), 'A'), unaccent(NEW.name), NEW.id)

      ON CONFLICT (team_id) DO UPDATE SET
        search_index = setweight(to_tsvector('simple', unaccent(NEW.name)), 'A'),
        title = unaccent(NEW.name),
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

    # --- Messages

    execute("""
    CREATE OR REPLACE FUNCTION refresh_messages_search()
    RETURNS TRIGGER LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO searches (organization_id, resource_type, updated_at, search_index, title, message_id)
      VALUES (NEW.organization_id, 'message', NEW.updated_at, setweight(to_tsvector('simple', unaccent(NEW.title)), 'A') || setweight(to_tsvector('simple', unaccent(NEW.content)), 'B'), unaccent(NEW.title), NEW.id)

      ON CONFLICT (message_id) DO UPDATE SET
        search_index = setweight(to_tsvector('simple', unaccent(NEW.title)), 'A') || setweight(to_tsvector('simple', unaccent(NEW.content)), 'B'),
        title = unaccent(NEW.title),
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

    # --- Documents pages
  end

  def down do
    execute("DROP TRIGGER refresh_teams_search_trigger ON teams;")
    execute("DROP FUNCTION refresh_teams_search;")

    execute("DROP TRIGGER refresh_messages_search_trigger ON messages;")
    execute("DROP FUNCTION refresh_messages_search;")

    drop(table(:searches))
    Palapa.Searches.SearchResourceTypeEnum.drop_type()
  end
end
