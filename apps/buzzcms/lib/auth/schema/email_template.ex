defmodule Buzzcms.Schema.EmailTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:type, :title, :html, :text]
  @optional_fields [:email_sender_id]

  schema "email_template" do
    field :type, :string
    field :subject, :string
    field :html, :string
    field :text, :string
    field :link, :string
    belongs_to :email_sender, Buzzcms.Schema.EmailSender
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
