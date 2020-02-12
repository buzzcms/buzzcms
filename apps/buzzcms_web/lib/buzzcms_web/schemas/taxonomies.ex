defmodule BuzzcmsWeb.Schema.Taxonomies do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers

  alias BuzzcmsWeb.TaxonomyResolver

  @filter_ids []
  @input_ids []

  node object(:taxonomy) do
    field :code, non_null(:string)
    field :display_name, non_null(:string)

    field :entry_types, non_null(list_of(non_null(:entry_type))),
      resolve: dataloader(Data, :entry_types)
  end

  connection(node_type: :taxonomy) do
    edge do
      field :node, non_null(:taxonomy)
    end
  end

  input_object :taxonomy_input do
    field :code, :string
    field :display_name, :string
  end

  input_object :taxonomy_filter_input do
    field :code, :string_filter_input
  end

  object :taxonomy_queries do
    connection field :taxonomies, node_type: :taxonomy do
      arg(:filter, :taxonomy_filter_input)
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&TaxonomyResolver.list/2)
    end
  end

  object :taxonomy_mutations do
    payload field :create_taxonomy do
      input do
        field :data, :taxonomy_input
      end

      output do
        field :result, :taxonomy_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&TaxonomyResolver.create/2)
    end

    payload field :edit_taxonomy do
      input do
        field :id, :id
        field :data, :taxonomy_input
      end

      output do
        field :result, :taxonomy_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&TaxonomyResolver.edit/2)
    end

    payload field :delete_taxonomy do
      input do
        field :id, :id
      end

      output do
        field :result, :taxonomy_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&TaxonomyResolver.delete/2)
    end
  end
end
