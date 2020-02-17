defmodule BuzzcmsWeb.Schema.Fields do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BuzzcmsWeb.FieldResolver

  @filter_ids []
  @input_ids []

  enum :field_type do
    value(:decimal)
    value(:boolean)
    value(:select)
    value(:multi_select)
    value(:time)
    value(:date)
    value(:datetime)
  end

  node object(:field) do
    field(:code, non_null(:string))
    field(:display_name, non_null(:string))
    field(:note, :string)
    field(:type, :field_type)
  end

  connection(node_type: :field) do
    edge do
      field(:node, non_null(:field))
    end
  end

  input_object :field_input do
    field(:code, :string)
    field(:display_name, :string)
    field(:note, :string)
    field(:type, :field_type)
  end

  input_object :field_filter_input do
    field(:code, :string_filter_input)
  end

  object :field_queries do
    connection field(:fields, node_type: :field) do
      arg(:filter, :field_filter_input)
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&FieldResolver.list/2)
    end
  end

  object :field_mutations do
    payload field(:create_field) do
      input do
        field(:data, :field_input)
      end

      output do
        field(:result, :field_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&FieldResolver.create/2)
    end

    payload field(:edit_field) do
      input do
        field(:id, :id)
        field(:data, :field_input)
      end

      output do
        field(:result, :field_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&FieldResolver.edit/2)
    end

    payload field(:delete_field) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :field_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&FieldResolver.delete/2)
    end
  end
end
