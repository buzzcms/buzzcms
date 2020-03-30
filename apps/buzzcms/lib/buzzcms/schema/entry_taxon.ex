defmodule Buzzcms.Schema.EntryTaxon do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "entry_taxon" do
    belongs_to :entry, Buzzcms.Schema.Entry
    belongs_to :taxon, Buzzcms.Schema.Taxon
    field :group, :string
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, [:entry_id, :taxon_id, :group])
    |> unique_constraint(:taxon, name: :entry_taxon_pkey)
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:taxon_id)
  end
end
