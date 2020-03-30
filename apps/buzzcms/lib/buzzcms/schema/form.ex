defmodule Buzzcms.Schema.Form do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:code, :display_name]
  @optional_fields [:note, :data, :send_from_email, :notify_emails]

  schema "form" do
    field :code, :string
    field :display_name, :string
    field :note, :string
    belongs_to :email_sender, Buzzcms.Schema.EmailSender
    field :notify_emails, {:array, :string}, default: []
    embeds_one :notify_template, Buzzcms.EmbeddedSchema.EmailTemplate, on_replace: :update
    embeds_one :thank_you_template, Buzzcms.EmbeddedSchema.EmailTemplate, on_replace: :update
    field :data, :map, default: %{fields: []}
    field :created_at, :utc_datetime
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> cast_embed(:notify_template)
    |> cast_embed(:thank_you_template)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
  end
end
