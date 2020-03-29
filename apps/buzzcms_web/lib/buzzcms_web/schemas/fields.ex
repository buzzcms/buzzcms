defmodule BuzzcmsWeb.Schema.Fields do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.FieldResolver
  import Absinthe.Resolution.Helpers

  enum :field_type do
    value(:integer)
    value(:decimal)
    value(:boolean)
    value(:select)
    value(:multi_select)
    value(:time)
    value(:date)
    value(:datetime)
    value(:color)
    value(:checkbox_group)
    value(:radio_group)
    value(:rich_text)
    value(:image)
    value(:gallery)
    value(:google_map)
    value(:menu)
    value(:theme)
    value(:json)
  end

  node object(:field) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :code, non_null(:string)
    field :display_name, non_null(:string)
    field :position, :integer
    field :note, :string
    field :type, :field_type
    field(:values, non_null(list_of(non_null(:field_value))), resolve: dataloader(Data, :values))
  end

  connection(node_type: :field) do
    field :count, non_null(:integer)

    edge do
      field(:node, non_null(:field))
    end
  end

  input_object :field_input do
    field :code, :string
    field :display_name, :string
    field :type, :field_type
    field :position, :integer
    field :note, :string
  end

  input_object :create_field_data_input do
    field :code, non_null(:string)
    field :display_name, non_null(:string)
    field :type, non_null(:field_type)
    field :position, :integer
    field :note, :string
  end

  input_object :field_filter_input do
    field :code, :string_filter_input
    field :display_name, :string_filter_input
    field :type, :string_filter_input
  end

  object :field_queries do
    connection field(:fields, node_type: :field) do
      arg(:offset, :integer)
      arg(:filter, :field_filter_input)
      arg(:order_by, list_of(non_null(:order_by_input)))
      resolve(&FieldResolver.list/2)
    end
  end

  object :field_mutations do
    payload field(:create_field) do
      input do
        field(:data, :create_field_data_input)
      end

      output do
        field(:result, :field_edge)
      end

      resolve(&FieldResolver.create/2)
    end

    payload field(:edit_field) do
      input do
        field :id, non_null(:id)
        field(:data, :field_input)
      end

      output do
        field(:result, :field_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :field)
      resolve(&FieldResolver.edit/2)
    end

    payload field(:delete_field) do
      input do
        field :id, non_null(:id)
      end

      output do
        field(:result, :field_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :field)
      resolve(&FieldResolver.delete/2)
    end
  end
end
