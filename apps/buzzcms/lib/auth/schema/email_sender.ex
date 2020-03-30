defmodule Buzzcms.Schema.EmailSender do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:name, :email]
  @optional_fields [:is_verified, :provider]

  schema "email_sender" do
    field :email, :string
    field :name, :string
    field :is_verified, :boolean
    field :provider, :string
    field :created_at, :utc_datetime
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
