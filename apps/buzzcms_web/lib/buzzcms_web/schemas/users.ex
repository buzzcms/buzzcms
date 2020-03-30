defmodule BuzzcmsWeb.Schema.Users do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BuzzcmsWeb.UserResolver

  node object(:user) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :email, :string
    field :nickname, :string
    field :display_name, :string
    field :avatar, :string
    field :bio, :string
    field :website, :string
  end

  connection(node_type: :user) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:user))
    end
  end

  input_object :user_filter_input do
    field :email, :string_filter_input
    field :nickname, :string_filter_input
  end

  object :user_queries do
    connection field(:users, node_type: :user) do
      arg(:filter, :user_filter_input)
      arg(:order_by, list_of(non_null(:order_by_input)))
      resolve(&UserResolver.list/2)
    end
  end
end
