defmodule BuzzcmsWeb.Schema.OptionValues do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers

  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.OptionValueResolver

  @filter_ids []
  @input_ids []

  node object(:option_value) do
    field(:value, non_null(:string))

    field :option_values, non_null(list_of(non_null(:option_value))),
      resolve: dataloader(Data, :option_values)
  end

  connection(node_type: :option_value) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:option_value))
    end
  end

  input_object :option_value_input do
    field(:value, :string)
  end

  input_object :option_value_filter_input do
    field(:code, :string_filter_input)
  end

  object :option_value_queries do
    connection field(:option_values, node_type: :option_value) do
      arg(:filter, :option_value_filter_input)
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&OptionValueResolver.list/2)
    end
  end

  object :option_value_mutations do
    payload field(:create_option_value) do
      input do
        field(:data, :option_value_input)
      end

      output do
        field(:result, :option_value_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&OptionValueResolver.create/2)
    end

    payload field(:edit_option_value) do
      input do
        field(:id, :id)
        field(:data, :option_value_input)
      end

      output do
        field(:result, :option_value_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&OptionValueResolver.edit/2)
    end

    payload field(:delete_option_value) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :option_value_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&OptionValueResolver.delete/2)
    end
  end
end
