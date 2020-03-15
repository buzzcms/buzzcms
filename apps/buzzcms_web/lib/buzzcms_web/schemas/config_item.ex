defmodule BuzzcmsWeb.Schema.ConfigItems do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BuzzcmsWeb.ConfigItemResolver

  @filter_ids []
  @input_ids [id: :config_item]

  node object(:config_item) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :code, non_null(:string)
    field :display_name, non_null(:string)
    field :note, :string
    field :type, :field_type
    field :data, :json
    field :created_at, non_null(:datetime)
  end

  connection(node_type: :config_item) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:config_item))
    end
  end

  input_object :config_item_input do
    field :code, :string
    field :display_name, :string
    field :type, :field_type
    field :data, :json
    field :note, :string
  end

  input_object :config_item_filter_input do
    field :code, :string_filter_input
    field :display_name, :string_filter_input
    field :type, :string_filter_input
  end

  enum :config_item_order_field do
    value(:code)
    value(:created_at)
  end

  input_object :config_item_order_by_input do
    field :field, non_null(:config_item_order_field)
    field :direction, non_null(:order_direction)
  end

  object :config_item_queries do
    connection field(:config_items, node_type: :config_item) do
      arg(:filter, :config_item_filter_input)
      arg(:order_by, list_of(non_null(:config_item_order_by_input)))
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&ConfigItemResolver.list/2)
    end
  end

  object :config_item_mutations do
    payload field(:create_config_item) do
      input do
        field :data, :config_item_input
      end

      output do
        field :result, :config_item_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&ConfigItemResolver.create/2)
    end

    payload field(:edit_config_item) do
      input do
        field :id, :id
        field :data, :config_item_input
      end

      output do
        field :result, :config_item_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&ConfigItemResolver.edit/2)
    end

    payload field(:delete_config_item) do
      input do
        field :id, :id
      end

      output do
        field :result, :config_item_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&ConfigItemResolver.delete/2)
    end
  end
end
