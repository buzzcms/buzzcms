defmodule Buzzcms.Migration do
  @moduledoc """
  Additional helpers for PostgreSQL.
  """

  import Ecto.Migration, only: [execute: 2]

  defmacro __using__(_) do
    quote do
      use Ecto.Migration
      import unquote(__MODULE__)
    end
  end

  def create_extension(names) when is_list(names) do
    Enum.each(names, &create_extension/1)
  end

  def create_extension(name) do
    execute(
      """
      CREATE EXTENSION IF NOT EXISTS "#{name}";
      """,
      """
      DROP EXTENSION IF EXISTS "#{name}";
      """
    )
  end

  @doc """

  """
  def create_function__update_modified_at do
    execute(
      """
      CREATE FUNCTION update_modified_at()
        RETURNS TRIGGER
        AS $$
      BEGIN
        NEW.modified_at = now();
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      """,
      "DROP FUNCTION update_modified_at;"
    )
  end

  def create_function__get_default_enum() do
    execute(
      """
      CREATE FUNCTION get_default_enum(tbl TEXT)
      RETURNS TEXT
      AS $$
      DECLARE
      _value TEXT;
      BEGIN
      SELECT value INTO _value FROM "enum_default_value" WHERE enum = tbl;
      RETURN _value;
      END $$ LANGUAGE plpgsql;
      """,
      "DROP FUNCTION get_default_enum;"
    )
  end

  @doc """

  """
  def create_update_modified_at_trigger(table) do
    execute(
      """
      CREATE TRIGGER #{table}_update_modified_at
        BEFORE UPDATE ON #{table}
        FOR EACH ROW
        EXECUTE PROCEDURE update_modified_at();
      """,
      "DROP TRIGGER #{table}_update_modified_at on #{table};"
    )
  end

  def create_unique_contraint(table, columns) do
    name = "#{table}_#{Enum.join(columns, "_")}"
    columns_text = columns |> Enum.map(&~s("#{&1}")) |> Enum.join(",")

    execute(
      """
      ALTER TABLE "#{table}"
      ADD CONSTRAINT #{name}_unique UNIQUE (#{columns_text});
      """,
      """
      ALTER TABLE "#{table}" DROP CONSTRAINT #{name}_unique;
      """
    )
  end

  def create_trigger(name: name, table: table, trigger: trigger, function: function) do
    execute(
      """
      CREATE TRIGGER "#{name}"
      #{trigger} ON "#{table}"
      FOR EACH ROW
      EXECUTE PROCEDURE #{function}();
      """,
      """
      DROP TRIGGER "#{name}" ON "#{table}"
      """
    )
  end
end
