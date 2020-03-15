defmodule BuzzcmsWeb.Schema.Subscribers do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BuzzcmsWeb.SubscriberResolver

  @filter_ids [
    filter: [
      form_id: BuzzcmsWeb.ParseIDsHelper.get_ids(:form)
    ]
  ]
  @input_ids [id: :subscriber, data: [form_id: :form]]

  node object(:subscriber) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :email, :string
    field :phone, :string
    field :name, :string
    field :data, :json
    field :labels, :json
    field :form_id, :id
    field :created_at, non_null(:datetime)
  end

  connection(node_type: :subscriber) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:subscriber))
    end
  end

  input_object :subscriber_input do
    field :email, :string
    field :phone, :string
    field :name, :string
    field :data, :json
    field :form_id, :id
    field :labels, :json
  end

  input_object :subscriber_filter_input do
    field :email, :string_filter_input
    field :phone, :string_filter_input
    field :name, :string_filter_input
    field :form_id, :id_filter_input
  end

  enum :subscriber_order_field do
    value(:created_at)
  end

  input_object :subscriber_order_by_input do
    field :field, non_null(:subscriber_order_field)
    field :direction, non_null(:order_direction)
  end

  object :subscriber_queries do
    connection field(:subscribers, node_type: :subscriber) do
      arg(:filter, :subscriber_filter_input)
      arg(:order_by, list_of(non_null(:subscriber_order_by_input)))
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&SubscriberResolver.list/2)
    end
  end

  object :subscriber_mutations do
    payload field(:create_subscriber) do
      input do
        field :data, :subscriber_input
      end

      output do
        field :result, :subscriber_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&SubscriberResolver.create/2)
    end

    payload field(:edit_subscriber) do
      input do
        field :id, :id
        field :data, :subscriber_input
      end

      output do
        field :result, :subscriber_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&SubscriberResolver.edit/2)
    end

    payload field(:delete_subscriber) do
      input do
        field :id, :id
      end

      output do
        field :result, :subscriber_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&SubscriberResolver.delete/2)
    end
  end
end
