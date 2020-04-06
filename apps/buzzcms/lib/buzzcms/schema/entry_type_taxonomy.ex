defmodule Buzzcms.Schema.EntryTypeTaxonomy do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "entry_type_taxonomy" do
    belongs_to :entry_type, Buzzcms.Schema.EntryType
    belongs_to :taxonomy, Buzzcms.Schema.Taxonomy
    field :position, :integer
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, [:entry_type_id, :taxonomy_id, :position])
    |> unique_constraint(:taxonomy, name: :entry_type_taxonomy_pkey)
    |> foreign_key_constraint(:entry_type_id)
    |> foreign_key_constraint(:taxonomy_id)
  end
end
