defmodule BuzzcmsWeb.Schema.EntryTypeTaxonomies do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  input_object :entry_type_taxonomy_input do
    field(:entry_type_id, :id)
    field(:taxonomy_id, :id)
  end

  object :entry_type_taxonomy_mutations do
    payload field(:create_entry_type_taxonomy) do
      input do
        field(:data, :entry_type_taxonomy_input)
      end

      output do
        field(:entry_type, :entry_type)
        field(:taxonomy, :taxonomy)
      end

      resolve(&BuzzcmsWeb.EntryTypeTaxonomyResolver.create/2)
    end

    payload field(:delete_entry_type_taxonomy) do
      input do
        field(:data, :entry_type_taxonomy_input)
      end

      output do
        field(:entry_type, :entry_type)
        field(:taxonomy, :taxonomy)
      end

      resolve(&BuzzcmsWeb.EntryTypeTaxonomyResolver.delete/2)
    end
  end
end
