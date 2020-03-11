defmodule Buzzcms.Schema.Field do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum

  defenum(FieldTypeEnum,
    integer: "integer",
    decimal: "decimal",
    boolean: "boolean",
    select: "select",
    multi_select: "multi_select",
    time: "time",
    date: "date",
    datetime: "datetime",
    color: "color",
    checkbox_group: "checkbox_group",
    radio_group: "radio_group",
    rich_text: "rich_text",
    image: "image",
    gallery: "gallery",
    google_map: "google_map",
    json: "json"
  )

  @required_fields [:code, :display_name, :type, :position]
  @optional_fields [:note]

  schema "field" do
    field :code, :string
    field :display_name, :string
    field :note, :string
    field :position, :integer
    has_many :values, Buzzcms.Schema.FieldValue
    field :type, FieldTypeEnum
    field :created_at, :utc_datetime
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
  end
end
