defmodule BuzzcmsWeb.Schema.OptionValues do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers

  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.OptionValueResolver

  node object(:option_value) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field(:code, non_null(:string))
    field(:display_name, non_null(:string))
    field(:option_type_id, non_null(:id))
    field :option_type, non_null(:option_type), resolve: dataloader(Data, :option_type)
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

      resolve(&OptionValueResolver.edit/2)
    end

    payload field(:delete_option_value) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :option_value_edge)
      end

      resolve(&OptionValueResolver.delete/2)
    end
  end
end
