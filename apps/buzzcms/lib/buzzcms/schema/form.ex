defmodule Buzzcms.Schema.Form do
  use Ecto.Schema
  import Ecto.Changeset

  @required_forms [:code, :display_name]
  @optional_forms [:note, :data]

  schema "form" do
    field :code, :string
    field :display_name, :string
    field :note, :string
    field :data, :map, default: %{fields: []}
    field :created_at, :utc_datetime
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_forms ++ @optional_forms)
    |> validate_required(@required_forms)
    |> unique_constraint(:code)
  end
end
