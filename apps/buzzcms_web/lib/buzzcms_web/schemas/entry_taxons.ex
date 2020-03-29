defmodule BuzzcmsWeb.Schema.EntryTaxons do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers

  alias BuzzcmsWeb.Data

  input_object :entry_taxon_input do
    field :entry_id, non_null(:id)
    field :taxon_id, non_null(:id)
    field :group, :string
  end

  node object(:entry_taxon) do
    field :entry, non_null(:entry), resolve: dataloader(Data, :entry)
    field :taxon, non_null(:taxon), resolve: dataloader(Data, :taxon)
    field :group, :string
  end

  object :entry_taxon_mutations do
    payload field(:create_entry_taxon) do
      input do
        field(:data, :entry_taxon_input)
      end

      output do
        field(:entry, :entry)
        field(:taxon, :taxon)
      end

      resolve(&BuzzcmsWeb.EntryTaxonResolver.create/2)
    end

    payload field(:delete_entry_taxon) do
      input do
        field(:data, :entry_taxon_input)
      end

      output do
        field(:entry, :entry)
        field(:taxon, :taxon)
      end

      resolve(&BuzzcmsWeb.EntryTaxonResolver.delete/2)
    end
  end
end
