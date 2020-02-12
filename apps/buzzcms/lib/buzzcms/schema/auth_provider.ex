defmodule Buzzcms.Schema.AuthProvider do
  use Ecto.Schema

  @primary_key false

  schema "auth_provider" do
    field :value, :string
    field :comment, :string
  end
end
