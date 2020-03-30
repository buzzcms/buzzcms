defmodule Buzzcms.Schema.EntryTypeField do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "entry_type_field" do
    belongs_to :entry_type, Buzzcms.Schema.EntryType
    belongs_to :field, Buzzcms.Schema.Field
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, [:entry_type_id, :field_id])
    |> unique_constraint(:field, name: :entry_type_field_pkey)
    |> foreign_key_constraint(:entry_type_id)
    |> foreign_key_constraint(:field_id)
  end
end
