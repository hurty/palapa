defmodule Palapa.Repo.Migrations.AddCommentsCountToMessages do
  use Ecto.Migration

  def up do
    alter table(:messages) do
      add(:comments_count, :integer, null: false, default: 0)
    end

    execute("""
    CREATE OR REPLACE FUNCTION update_message_comments_count()
    RETURNS trigger as $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE messages
        SET comments_count = comments_count + 1
        WHERE id = NEW.message_id;
        RETURN NEW;
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE messages
        SET comments_count = comments_count - 1
        WHERE id = OLD.message_id;
        RETURN OLD;
      END IF;
      RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER update_comments_count_trigger
    AFTER INSERT OR DELETE
    ON message_comments
    FOR EACH ROW
    EXECUTE PROCEDURE update_message_comments_count();
    """)
  end

  def down do
    alter table(:messages) do
      remove(:comments_count)
    end

    execute("DROP TRIGGER IF EXISTS update_comments_count_trigger ON message_comments;")
    execute("DROP FUNCTION update_message_comments_count();")
  end
end
