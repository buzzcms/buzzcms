defmodule Buzzcms.Schema.Role do
  use Ecto.Schema

  @primary_key false

  schema "role" do
    field :value, :string
    field :comment, :string
    field :is_default, :boolean
  end
end
