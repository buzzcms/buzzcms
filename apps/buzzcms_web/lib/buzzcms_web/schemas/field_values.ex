defmodule BuzzcmsWeb.Schema.FieldValues do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  alias BuzzcmsWeb.FieldValueResolver

  node object(:field_value) do
    field :code, non_null(:string)
    field :display_name, non_null(:string)
    field :position, :integer
    field :field_id, non_null(:id)
    # field :field, non_null(:field), resolve: dataloader(Data, :field)
  end

  connection(node_type: :field_value) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:field_value))
    end
  end

  input_object :field_value_input do
    field(:code, :string)
    field(:display_name, :string)
    field :position, :integer
    field(:field_id, :id)
  end

  input_object :field_value_filter_input do
    field(:code, :string_filter_input)
    field(:display_name, :string_filter_input)
    field(:field_id, :id_filter_input)
  end

  object :field_value_queries do
    connection field(:field_values, node_type: :field_value) do
      arg(:filter, :field_value_filter_input)
      arg(:order_by, list_of(non_null(:order_by_input)))
      resolve(&FieldValueResolver.list/2)
    end
  end

  object :field_value_mutations do
    payload field(:create_field_value) do
      input do
        field(:data, :field_value_input)
      end

      output do
        field(:result, :field_value_edge)
      end

      resolve(&FieldValueResolver.create/2)
    end

    payload field(:edit_field_value) do
      input do
        field(:id, :id)
        field(:data, :field_value_input)
      end

      output do
        field(:result, :field_value_edge)
      end

      resolve(&FieldValueResolver.edit/2)
    end

    payload field(:delete_field_value) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :field_value_edge)
      end

      resolve(&FieldValueResolver.delete/2)
    end
  end
end
