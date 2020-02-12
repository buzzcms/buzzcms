defmodule Buzzcms.Schema.Route do
  use Ecto.Schema

  schema "route" do
    field :name, :string
    field :pattern, :string
    field :heading, :map
    field :data, :map
    field :seo, :map
  end
end
