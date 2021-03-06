defmodule Buzzcms.Schema.EntryBooleanValue do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:entry_id, :field_id, :value]
  @optional_fields []
  @primary_key false

  schema "entry_boolean_value" do
    belongs_to :entry, Buzzcms.Schema.Entry
    belongs_to :field, Buzzcms.Schema.Field
    field :value, :boolean
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
