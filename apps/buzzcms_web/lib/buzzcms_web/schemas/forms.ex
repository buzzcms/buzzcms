defmodule BuzzcmsWeb.Schema.Forms do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers
  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.FormResolver

  node object(:form) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :code, non_null(:string)
    field :display_name, non_null(:string)
    field :note, :string
    field :data, :json
    field :notify_template, :email_template, resolve: dataloader(Data, :notify_template)
    field :thank_you_template, :email_template, resolve: dataloader(Data, :thank_you_template)
    field :notify_emails, non_null(list_of(non_null(:string)))
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
    field :notify_emails, list_of(non_null(:string))
    field :notify_template_id, :id
    field :thank_you_template_id, :id
  end

  input_object :create_form_data_input do
    field :code, non_null(:string)
    field :display_name, non_null(:string)
    field :data, non_null(:json)
    field :notify_emails, non_null(list_of(non_null(:string)))
    field :notify_template_id, non_null(:id)
    field :thank_you_template_id, non_null(:id)
    field :note, :string
  end

  input_object :form_filter_input do
    field :code, :string_filter_input
    field :display_name, :string_filter_input
  end

  object :form_queries do
    connection field(:forms, node_type: :form) do
      arg(:filter, :form_filter_input)
      arg(:order_by, list_of(non_null(:order_by_input)))
      resolve(&FormResolver.list/2)
    end
  end

  object :form_mutations do
    payload field(:create_form) do
      input do
        field :data, :create_form_data_input
      end

      output do
        field :result, :form_edge
      end

      resolve(&FormResolver.create/2)
    end

    payload field(:edit_form) do
      input do
        field :id, non_null(:id)
        field :data, :form_input
      end

      output do
        field :result, :form_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :form)
      resolve(&FormResolver.edit/2)
    end

    payload field(:delete_form) do
      input do
        field :id, non_null(:id)
      end

      output do
        field :result, :form_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :form)
      resolve(&FormResolver.delete/2)
    end
  end
end
