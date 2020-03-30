defmodule Buzzcms.Schema.EmailTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [
    :code,
    :subject,
    :html,
    :text,
    :email_sender_id
  ]
  @optional_fields [:note, :is_system]

  schema "email_template" do
    field :code, :string
    field :note, :string
    field :is_system, :boolean, default: false
    field :subject, :string
    field :html, :string
    field :text, :string
    belongs_to :email_sender, Buzzcms.Schema.EmailSender
    field :created_at, :utc_datetime
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
