defmodule BuzzcmsWeb.Schema.EntryTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers

  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.EntryTypeResolver

  node object(:entry_type) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :code, non_null(:string)
    field :display_name, non_null(:string)
    field :is_product, non_null(:boolean)
    field :config, non_null(:entry_type_config)
    field :fields, non_null(list_of(non_null(:field))), resolve: dataloader(Data, :fields)

    field :taxonomies, non_null(list_of(non_null(:taxonomy))),
      resolve: dataloader(Data, :taxonomies)
  end

  connection(node_type: :entry_type) do
    field :count, non_null(:integer)

    edge do
      field :node, non_null(:entry_type)
    end
  end

  input_object :entry_type_input do
    field :code, :string
    field :display_name, :string
    field :is_product, :boolean
  end

  input_object :create_entry_type_data_input do
    field :code, non_null(:string)
    field :display_name, non_null(:string)
    field :is_product, :boolean
  end

  input_object :entry_type_filter_input do
    field :code, :string_filter_input
    field :is_product, :boolean_filter_input
  end

  object :entry_type_queries do
    connection field(:entry_types, node_type: :entry_type) do
      arg(:filter, :entry_type_filter_input)
      arg(:limit, :integer)
      resolve(&EntryTypeResolver.list/2)
    end
  end

  object :entry_type_mutations do
    payload field(:create_entry_type) do
      input do
        field(:data, :create_entry_type_data_input)
      end

      output do
        field(:result, :entry_type_edge)
      end

      resolve(&EntryTypeResolver.create/2)
    end

    payload field(:edit_entry_type) do
      input do
        field :id, non_null(:id)
        field(:data, :entry_type_input)
      end

      output do
        field(:result, :entry_type_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :entry_type)
      resolve(&EntryTypeResolver.edit/2)
    end

    payload field(:delete_entry_type) do
      input do
        field :id, non_null(:id)
      end

      output do
        field(:result, :entry_type_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :entry_type)
      resolve(&EntryTypeResolver.delete/2)
    end
  end
end
