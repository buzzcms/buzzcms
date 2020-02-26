defmodule Buzzcms.Schema.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:slug, :title, :entry_type_id]
  @optional_fields [:description, :body, :rich_text, :image, :images]

  schema "entry" do
    # field :nanoid, :string
    field :slug, :string
    field :title, :string
    field :description, :string
    field :body, :string
    field :image, :string
    field :images, {:array, :string}
    field :rich_text, {:array, :map}
    belongs_to :entry_type, Buzzcms.Schema.EntryType
    belongs_to :taxon, Buzzcms.Schema.Taxon
    has_one :product, Buzzcms.Schema.Product
    has_many :entry_taxons, Buzzcms.Schema.EntryTaxon
    many_to_many :taxons, Buzzcms.Schema.Taxon, join_through: "entry_taxon"
    many_to_many :select_values, Buzzcms.Schema.FieldValue, join_through: "entry_select_value"
    field :state, :string
    field :published_at, :utc_datetime
    field :created_at, :utc_datetime
    field :modified_at, :utc_datetime
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:slug, name: :entry_slug_unique)
  end
end
