defmodule Buzzcms.Schema.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  @required_forms [:form_id, :data]
  @optional_forms [:email, :phone, :name, :labels]

  schema "subscriber" do
    field :email, :string
    field :phone, :string
    field :name, :string
    belongs_to :form, Buzzcms.Schema.Form
    field :labels, :map
    field :data, :map
    field :created_at, :utc_datetime
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_forms ++ @optional_forms)
    |> validate_required(@required_forms)
    |> unique_constraint(:code)
  end
end
