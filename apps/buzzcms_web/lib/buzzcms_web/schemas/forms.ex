defmodule BuzzcmsWeb.Schema.Forms do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BuzzcmsWeb.FormResolver

  @filter_ids []
  @input_ids [id: :form]

  node object(:form) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :code, non_null(:string)
    field :display_name, non_null(:string)
    field :note, :string
    field :data, :json
    field :created_at, non_null(:datetime)
  end

  connection(node_type: :form) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:form))
    end
  end

  input_object :form_input do
    field :code, :string
    field :display_name, :string
    field :data, :json
    field :note, :string
  end

  input_object :form_filter_input do
    field :code, :string_filter_input
    field :display_name, :string_filter_input
  end

  enum :form_order_field do
    value(:code)
    value(:created_at)
  end

  input_object :form_order_by_input do
    field :field, non_null(:form_order_field)
    field :direction, non_null(:order_direction)
  end

  object :form_queries do
    connection field(:forms, node_type: :form) do
      arg(:filter, :form_filter_input)
      arg(:order_by, list_of(non_null(:form_order_by_input)))
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&FormResolver.list/2)
    end
  end

  object :form_mutations do
    payload field(:create_form) do
      input do
        field :data, :form_input
      end

      output do
        field :result, :form_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&FormResolver.create/2)
    end

    payload field(:edit_form) do
      input do
        field :id, :id
        field :data, :form_input
      end

      output do
        field :result, :form_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&FormResolver.edit/2)
    end

    payload field(:delete_form) do
      input do
        field :id, :id
      end

      output do
        field :result, :form_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&FormResolver.delete/2)
    end
  end
end
