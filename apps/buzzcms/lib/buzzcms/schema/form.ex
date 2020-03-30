defmodule Buzzcms.Schema.Form do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [
    :code,
    :display_name
  ]
  @optional_fields [
    :note,
    :data,
    :notify_template_id,
    :thank_you_template_id,
    :notify_emails
  ]

  schema "form" do
    field :code, :string
    field :display_name, :string
    field :note, :string
    belongs_to :notify_template, Buzzcms.Schema.EmailTemplate
    belongs_to :thank_you_template, Buzzcms.Schema.EmailTemplate
    field :notify_emails, {:array, :string}, default: []
    field :data, :map, default: %{fields: []}
    field :created_at, :utc_datetime
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
  end
end
