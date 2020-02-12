defmodule BuzzcmsWeb.Schema.EntryTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers

  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.EntryTypeResolver

  @filter_ids []
  @input_ids []

  node object(:entry_type) do
    field :code, non_null(:string)
    field :display_name, non_null(:string)

    field :taxonomies, non_null(list_of(non_null(:taxonomy))),
      resolve: dataloader(Data, :taxonomies)
  end

  connection(node_type: :entry_type) do
    edge do
      field :node, non_null(:entry_type)
    end
  end

  input_object :entry_type_input do
    field :code, :string
    field :display_name, :string
  end

  input_object :entry_type_filter_input do
    field :code, :string_filter_input
  end

  object :entry_type_queries do
    connection field :entry_types, node_type: :entry_type do
      arg(:filter, :entry_filter_input)
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&EntryTypeResolver.list/2)
    end
  end

  object :entry_type_mutations do
    payload field :create_entry_type do
      input do
        field :data, :entry_type_input
      end

      output do
        field :result, :entry_type_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&EntryTypeResolver.create/2)
    end

    payload field :edit_entry_type do
      input do
        field :id, :id
        field :data, :entry_type_input
      end

      output do
        field :result, :entry_type_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&EntryTypeResolver.edit/2)
    end

    payload field :delete_entry_type do
      input do
        field :id, :id
      end

      output do
        field :result, :entry_type_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&EntryTypeResolver.delete/2)
    end
  end
end
