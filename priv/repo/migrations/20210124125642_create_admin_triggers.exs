defmodule NudgeApi.Repo.Migrations.CreateAdminTriggers do
  use Ecto.Migration


  def up do
    # Create a function that broadcasts row changes
    execute "
      CREATE OR REPLACE FUNCTION broadcast_changes()
      RETURNS trigger AS $$
      DECLARE
        current_row RECORD;
      BEGIN
        IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
          current_row := NEW;
        ELSE
          current_row := OLD;
        END IF;
        IF (TG_OP = 'INSERT') THEN
          OLD := NEW;
        END IF;
      PERFORM pg_notify(
          'table_changes',
          json_build_object(
            'table', TG_TABLE_NAME,
            'type', TG_OP,
            'id', current_row.id,
            'new_row_data', row_to_json(NEW),
            'old_row_data', row_to_json(OLD)
          )::text
        );
      RETURN current_row;
      END;
      $$ LANGUAGE plpgsql;"

    # Create a trigger that links USER_MATCHES ON INSERT with INITIATOR to the broadcast function
    execute "DROP TRIGGER IF EXISTS notify_table_changes_trigger ON user_matches;"
    execute "CREATE TRIGGER notify_table_changes_trigger AFTER INSERT ON user_matches FOR EACH ROW WHEN (NEW.initiator) EXECUTE PROCEDURE broadcast_changes();"

    # Create a trigger that links MEETINGS ON UPDATE location to the broadcast function
    execute "DROP TRIGGER IF EXISTS notify_table_changes_trigger ON meetings;"
    execute "CREATE TRIGGER notify_table_changes_trigger AFTER UPDATE OF location ON meetings FOR EACH ROW EXECUTE PROCEDURE broadcast_changes();"
  end

  def down do
    execute "DROP TRIGGER IF EXISTS notify_table_changes_trigger on meetings;"
    execute "DROP TRIGGER IF EXISTS notify_table_changes_trigger on user_matches;"
  end
end
