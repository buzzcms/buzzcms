defmodule BuzzcmsWeb.Schema.EmailSenders do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BuzzcmsWeb.EmailSenderResolver

  node object(:email_sender) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :email, non_null(:string)
    field :name, non_null(:string)
    field :provider, non_null(:string)
    field :is_verified, :boolean
    field :created_at, non_null(:datetime)
  end

  connection(node_type: :email_sender) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:email_sender))
    end
  end

  input_object :email_sender_input do
    field :email, :string
    field :name, :string
    field :provider, :string
  end

  input_object :create_email_sender_data_input do
    field :email, non_null(:string)
    field :name, non_null(:string)
    field :provider, non_null(:string)
  end

  input_object :email_sender_filter_input do
    field :email, :string_filter_input
    field :name, :string_filter_input
    field :provider, :string_filter_input
  end

  object :email_sender_queries do
    connection field(:email_senders, node_type: :email_sender) do
      arg(:filter, :email_sender_filter_input)
      arg(:order_by, list_of(non_null(:order_by_input)))
      resolve(&EmailSenderResolver.list/2)
    end
  end

  object :email_sender_mutations do
    payload field(:create_email_sender) do
      input do
        field :data, :create_email_sender_data_input
      end

      output do
        field :result, :email_sender_edge
      end

      resolve(&EmailSenderResolver.create/2)
    end

    payload field(:edit_email_sender) do
      input do
        field :id, :id
        field :data, :email_sender_input
      end

      output do
        field :result, :email_sender_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :email_sender)
      resolve(&EmailSenderResolver.edit/2)
    end

    payload field(:delete_email_sender) do
      input do
        field :id, :id
      end

      output do
        field :result, :email_sender_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :email_sender)
      resolve(&EmailSenderResolver.delete/2)
    end
  end
end
