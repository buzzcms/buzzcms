defmodule Buzzcms.Schema.Token do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:user_id, :type]
  @optional_fields [:is_used]

  schema "token" do
    belongs_to :user, Buzzcms.Schema.User, type: Ecto.UUID
    field :type, :string
    field :token, :string
    field :expired_at, :utc_datetime
    field :is_used, :boolean
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
