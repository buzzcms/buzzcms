defmodule BuzzcmsWeb.Schema.OptionTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers

  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.OptionTypeResolver

  @filter_ids []
  @input_ids []

  node object(:option_type) do
    field(:code, non_null(:string))
    field(:display_name, non_null(:string))

    field :option_values, non_null(list_of(non_null(:option_value))),
      resolve: dataloader(Data, :option_values)
  end

  connection(node_type: :option_type) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:option_type))
    end
  end

  input_object :option_type_input do
    field(:name, :string)
  end

  input_object :option_type_filter_input do
    field(:code, :string_filter_input)
  end

  object :option_type_queries do
    connection field(:option_types, node_type: :option_type) do
      arg(:filter, :option_type_filter_input)
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&OptionTypeResolver.list/2)
    end
  end

  object :option_type_mutations do
    payload field(:create_option_type) do
      input do
        field(:data, :option_type_input)
      end

      output do
        field(:result, :option_type_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&OptionTypeResolver.create/2)
    end

    payload field(:edit_option_type) do
      input do
        field(:id, :id)
        field(:data, :option_type_input)
      end

      output do
        field(:result, :option_type_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&OptionTypeResolver.edit/2)
    end

    payload field(:delete_option_type) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :option_type_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&OptionTypeResolver.delete/2)
    end
  end
end
