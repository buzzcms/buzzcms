defmodule Buzzcms.Schema.EntrySelectValue do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "entry_select_value" do
    belongs_to :entry, Buzzcms.Schema.Entry
    belongs_to :field_value, Buzzcms.Schema.FieldValue
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, [:entry_id, :field_value_id])
    |> unique_constraint(:field_value, name: :entry_field_value_pkey)
  end
end
