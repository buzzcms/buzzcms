defmodule Buzzcms.Schema.EntrySelectValue do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @required_fields [:entry_id, :field_id, :field_value_id]
  @optional_fields []

  schema "entry_select_value" do
    belongs_to :entry, Buzzcms.Schema.Entry
    belongs_to :field, Buzzcms.Schema.Field
    belongs_to :field_value, Buzzcms.Schema.FieldValue
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:field_value, name: :entry_field_value_pkey)
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:field_id)
    |> foreign_key_constraint(:field_value_id)
  end
end
