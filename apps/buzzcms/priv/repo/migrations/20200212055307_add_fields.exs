defmodule Buzzcms.Repo.Migrations.AddFields do
  use Buzzcms.Migration

  @field_types ~w('integer' 'decimal' 'boolean' 'select' 'multi_select' 'time' 'date' 'datetime')

  def change do
    create table(:field) do
      add :code, :string, null: false
      add :display_name, :string, null: false
      add :note, :string
      add :type, :string, null: false, default: "select"
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:field, [:code])

    create constraint(:field, :field_type, check: "type IN (#{Enum.join(@field_types, ", ")})")

    create table(:field_value) do
      add :code, :string, null: false
      add :display_name, :string, null: false
      add :field_id, references(:field), null: false
      add :position, :integer, default: 0, null: false
      add :description, :string, null: false
    end

    create_unique_contraint(:field_value, [:field_id, :code])
    create index(:field_value, [:field_id])

    create table(:entry_type_field, primary_key: false) do
      add :entry_type_id, references(:entry_type), primary_key: true, null: false
      add :field_id, references(:field), primary_key: true, null: false
      add :position, :integer, default: 0, null: false
    end

    create index(:entry_type_field, [:entry_type_id])
    create index(:entry_type_field, [:field_id])

    create table(:taxon_field, primary_key: false) do
      add :taxon_id, references(:taxon), primary_key: true, null: false
      add :field_id, references(:field), primary_key: true, null: false
      add :position, :integer, default: 0, null: false
    end

    create index(:taxon_field, [:taxon_id])
    create index(:taxon_field, [:field_id])

    # Entry integer value
    create table(:entry_integer_value, primary_key: false) do
      add :entry_id, references(:entry), primary_key: true, null: false
      add :field_id, references(:field), primary_key: true, null: false
      add :value, :integer, null: false
    end

    create index(:entry_integer_value, [:entry_id])
    create index(:entry_integer_value, [:field_id])
    create index(:entry_integer_value, [:value])

    # Entry decimal value
    create table(:entry_decimal_value, primary_key: false) do
      add :entry_id, references(:entry), primary_key: true, null: false
      add :field_id, references(:field), primary_key: true, null: false
      add :value, :decimal, null: false
    end

    create index(:entry_decimal_value, [:entry_id])
    create index(:entry_decimal_value, [:field_id])
    create index(:entry_decimal_value, [:value])

    # Entry boolean value
    create table(:entry_boolean_value, primary_key: false) do
      add :entry_id, references(:entry), primary_key: true, null: false
      add :field_id, references(:field), primary_key: true, null: false
      add :value, :boolean, null: false
    end

    create index(:entry_boolean_value, [:entry_id])
    create index(:entry_boolean_value, [:field_id])
    create index(:entry_boolean_value, [:value])

    # Entry date value
    create table(:entry_date_value, primary_key: false) do
      add :entry_id, references(:entry), primary_key: true, null: false
      add :field_id, references(:field), primary_key: true, null: false
      add :value, :date, null: false
    end

    create index(:entry_date_value, [:entry_id])
    create index(:entry_date_value, [:field_id])
    create index(:entry_date_value, [:value])

    # Entry time value
    create table(:entry_time_value, primary_key: false) do
      add :entry_id, references(:entry), primary_key: true, null: false
      add :field_id, references(:field), primary_key: true, null: false
      add :value, :time, null: false
    end

    create index(:entry_time_value, [:entry_id])
    create index(:entry_time_value, [:field_id])
    create index(:entry_time_value, [:value])

    # Entry datetime value
    create table(:entry_datetime_value, primary_key: false) do
      add :entry_id, references(:entry), primary_key: true, null: false
      add :field_id, references(:field), primary_key: true, null: false
      add :value, :utc_datetime, null: false
    end

    create index(:entry_datetime_value, [:entry_id])
    create index(:entry_datetime_value, [:field_id])
    create index(:entry_datetime_value, [:value])

    # Entry select value
    create table(:entry_select_value, primary_key: false) do
      add :entry_id, references(:entry), primary_key: true, null: false
      add :field_value_id, references(:field_value), primary_key: true, null: false
      add :field_id, references(:field), null: false
    end

    create index(:entry_select_value, [:entry_id])
    create index(:entry_select_value, [:field_id])
    create index(:entry_select_value, [:field_value_id])
  end
end
