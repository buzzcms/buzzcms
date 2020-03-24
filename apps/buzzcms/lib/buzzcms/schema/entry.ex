defmodule Buzzcms.Schema.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:slug, :title, :entry_type_id]
  @optional_fields [
    :subtitle,
    :description,
    :body,
    :rich_text,
    :featured,
    :image,
    :images,
    :state,
    :tags,
    :published_at
  ]

  schema "entry" do
    # field :nanoid, :string
    field :slug, :string
    field :title, :string
    field :subtitle, :string
    field :description, :string, default: ""
    field :featured, :boolean
    field :body, :string
    field :image, :string
    field :images, {:array, :map}
    field :rich_text, {:array, :map}
    field :tags, {:array, :string}, default: []
    embeds_one :seo, Buzzcms.EmbeddedSchema.Seo, on_replace: :update

    belongs_to :entry_type, Buzzcms.Schema.EntryType
    belongs_to :taxon, Buzzcms.Schema.Taxon
    has_one :product, Buzzcms.Schema.Product
    has_many :entry_taxons, Buzzcms.Schema.EntryTaxon
    many_to_many :taxons, Buzzcms.Schema.Taxon, join_through: "entry_taxon"
    many_to_many :select_values, Buzzcms.Schema.FieldValue, join_through: "entry_select_value"
    has_many :boolean_values, Buzzcms.Schema.EntryBooleanValue
    has_many :integer_values, Buzzcms.Schema.EntryIntegerValue
    has_many :decimal_values, Buzzcms.Schema.EntryDecimalValue
    has_many :date_values, Buzzcms.Schema.EntryDateValue
    has_many :time_values, Buzzcms.Schema.EntryTimeValue
    has_many :datetime_values, Buzzcms.Schema.EntryDatetimeValue
    has_many :json_values, Buzzcms.Schema.EntryJsonValue
    field :state, :string
    field :published_at, :utc_datetime
    field :created_at, :utc_datetime
    field :modified_at, :utc_datetime
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> cast_embed(:seo)
    |> validate_required(@required_fields)
    |> unique_constraint(:slug, name: :entry_slug_unique)
  end
end
