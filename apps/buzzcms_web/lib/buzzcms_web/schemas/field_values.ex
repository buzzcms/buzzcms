defmodule BuzzcmsWeb.Schema.FieldValues do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers

  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.FieldValueResolver

  @filter_ids [
    filter: [
      field_id: BuzzcmsWeb.ParseIDsHelper.get_ids(:field)
    ]
  ]
  @input_ids []

  node object(:field_value) do
    field(:code, non_null(:string))
    field(:display_name, non_null(:string))
    field :field, non_null(:field), resolve: dataloader(Data, :field)
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
  end

  input_object :field_value_filter_input do
    field(:code, :string_filter_input)
    field(:field_id, :id_filter_input)
  end

  object :field_value_queries do
    connection field(:field_values, node_type: :field_value) do
      arg(:filter, :field_value_filter_input)
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
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

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
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

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&FieldValueResolver.edit/2)
    end

    payload field(:delete_field_value) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :field_value_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&FieldValueResolver.delete/2)
    end
  end
end
