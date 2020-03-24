defmodule Buzzcms.Repo.Migrations.AddEntryValues do
  use Buzzcms.Migration

  def change do
    alter table(:entry) do
      add :values, :jsonb, default: "{}", null: false
    end

    create table(:field_index) do
      add :field, :string
      add :type, :string
    end

    create_unique_contraint(:field_index, [:field])

    create_function__create_field_index()
    create_function__delete_field_index()

    create_trigger(
      name: "field_index_create_field_index",
      table: "field_index",
      trigger: "AFTER INSERT",
      function: "create_field_index"
    )

    create_trigger(
      name: "field_index_delete_field_index",
      table: "field_index",
      trigger: "AFTER DELETE",
      function: "delete_field_index"
    )
  end

  defp create_function__create_field_index() do
    execute """
            CREATE FUNCTION create_field_index()
            RETURNS TRIGGER
            AS $$
            BEGIN
            EXECUTE format(
            'CREATE INDEX entry_field_%1$s ON entry((("values"->>''%1$s'')::%2$s))',
              NEW.field, NEW.type
            );
            RETURN NEW;
            END;
            $$
            LANGUAGE plpgsql;
            """,
            "DROP FUNCTION create_field_index"
  end

  defp create_function__delete_field_index() do
    execute """
            CREATE FUNCTION delete_field_index()
            RETURNS TRIGGER
            AS $$
            BEGIN
            EXECUTE format('DROP INDEX entry_field_%1$s', OLD.field);
            RETURN NEW;
            END;
            $$
            LANGUAGE plpgsql;
            """,
            "DROP FUNCTION delete_field_index"
  end
end
