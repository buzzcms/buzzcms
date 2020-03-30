defmodule Buzzcms.Schema.EntryJsonValue do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:entry_id, :field_id, :value]
  @optional_fields []
  @primary_key false

  schema "entry_json_value" do
    belongs_to :entry, Buzzcms.Schema.Entry
    belongs_to :field, Buzzcms.Schema.Field
    field :value, :map
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:field_id)
  end
end
