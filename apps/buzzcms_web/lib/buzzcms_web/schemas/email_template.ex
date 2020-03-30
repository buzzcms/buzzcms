defmodule BuzzcmsWeb.Schema.EmailTemplates do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers
  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.EmailTemplateResolver

  node object(:email_template) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :code, non_null(:string)
    field :note, :string
    field :is_system, :boolean
    field :subject, non_null(:string)
    field :html, non_null(:string)
    field :text, non_null(:string)
    field :email_sender_id, non_null(:id)
    field :email_sender, :email_sender, resolve: dataloader(Data, :email_sender)
    field :created_at, non_null(:datetime)
  end

  connection(node_type: :email_template) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:email_template))
    end
  end

  input_object :email_template_input do
    field :code, :string
    field :note, :string
    field :subject, :string
    field :html, :string
    field :text, :string
    field :email_sender_id, :id
  end

  input_object :create_email_template_data_input do
    field :code, non_null(:string)
    field :note, :string
    field :subject, non_null(:string)
    field :html, non_null(:string)
    field :text, non_null(:string)
    field :email_sender_id, :id
  end

  input_object :email_template_filter_input do
    field :code, :string_filter_input
    field :note, :string_filter_input
    field :subject, :string_filter_input
  end

  object :email_template_queries do
    connection field(:email_templates, node_type: :email_template) do
      arg(:filter, :email_template_filter_input)
      arg(:order_by, list_of(non_null(:order_by_input)))
      resolve(&EmailTemplateResolver.list/2)
    end
  end

  object :email_template_mutations do
    payload field(:create_email_template) do
      input do
        field :data, :create_email_template_data_input
      end

      output do
        field :result, :email_template_edge
      end

      resolve(&EmailTemplateResolver.create/2)
    end

    payload field(:edit_email_template) do
      input do
        field :id, :id
        field :data, :email_template_input
      end

      output do
        field :result, :email_template_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :email_template)
      resolve(&EmailTemplateResolver.edit/2)
    end

    payload field(:delete_email_template) do
      input do
        field :id, :id
      end

      output do
        field :result, :email_template_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :email_template)
      resolve(&EmailTemplateResolver.delete/2)
    end
  end
end
