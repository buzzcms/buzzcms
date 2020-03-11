defmodule Buzzcms.Repo.Migrations.RefineEntryFields do
  use Ecto.Migration

  @old_field_types ~w('integer' 'decimal' 'boolean' 'select' 'multi_select' 'time' 'date' 'datetime')
  @field_types [
                 "integer",
                 "decimal",
                 "boolean",
                 "select",
                 "multi_select",
                 "time",
                 "date",
                 "datetime",
                 "color",
                 "checkbox_group",
                 "radio_group",
                 "rich_text",
                 "image",
                 "gallery",
                 "google_map",
                 "json"
               ]
               |> Enum.map(&"'#{&1}'")

  def up do
    create table(:entry_json_value, primary_key: false) do
      add(:entry_id, references(:entry), primary_key: true, null: false)
      add(:field_id, references(:field), primary_key: true, null: false)
      add(:value, :jsonb, null: false)
    end

    create(index(:entry_json_value, [:entry_id]))
    create(index(:entry_json_value, [:field_id]))
    drop(constraint(:field, :field_type))
    create(constraint(:field, :field_type, check: "type IN (#{Enum.join(@field_types, ", ")})"))
  end

  def down do
    drop(constraint(:field, :field_type))

    create(
      constraint(:field, :field_type, check: "type IN (#{Enum.join(@old_field_types, ", ")})")
    )

    drop(index(:entry_json_value, [:field_id]))
    drop(index(:entry_json_value, [:entry_id]))
    drop(table(:entry_json_value))
  end
end
