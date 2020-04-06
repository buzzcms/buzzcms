defmodule BuzzcmsWeb.Schema.Taxonomies do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers

  alias BuzzcmsWeb.TaxonomyResolver

  node object(:taxonomy) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :code, non_null(:string)
    field :display_name, non_null(:string)

    field :entry_types,
          non_null(list_of(non_null(:entry_type))),
          resolve: dataloader(Data, :entry_types)
  end

  connection(node_type: :taxonomy) do
    field :count, non_null(:integer)

    edge do
      field :node, non_null(:taxonomy)
    end
  end

  input_object :taxonomy_input do
    field :code, :string
    field :display_name, :string
  end

  input_object :create_taxonomy_data_input do
    field :code, non_null(:string)
    field :display_name, non_null(:string)
  end

  input_object :taxonomy_filter_input do
    field :id, :id_filter_input
    field :code, :string_filter_input
    field :display_name, :string_filter_input
  end

  object :taxonomy_queries do
    connection field :taxonomies, node_type: :taxonomy do
      arg(:filter, :taxonomy_filter_input)
      resolve(&TaxonomyResolver.list/2)
    end
  end

  object :taxonomy_mutations do
    payload field :create_taxonomy do
      input do
        field :data, :create_taxonomy_data_input
      end

      output do
        field :result, :taxonomy_edge
      end

      resolve(&TaxonomyResolver.create/2)
    end

    payload field :edit_taxonomy do
      input do
        field :id, non_null(:id)
        field :data, :taxonomy_input
      end

      output do
        field :result, :taxonomy_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :taxonomy)
      resolve(&TaxonomyResolver.edit/2)
    end

    payload field :delete_taxonomy do
      input do
        field :id, non_null(:id)
      end

      output do
        field :result, :taxonomy_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :taxonomy)
      resolve(&TaxonomyResolver.delete/2)
    end
  end
end
