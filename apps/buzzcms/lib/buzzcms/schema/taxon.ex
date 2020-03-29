defmodule Buzzcms.Schema.Taxon do
  use Ecto.Schema
  import Ecto.Changeset
  alias EctoLtree.LabelTree, as: Ltree

  @required_fields [:slug, :title, :taxonomy_id]
  @optional_fields [
    :subtitle,
    :description,
    :body,
    :rich_text,
    :featured,
    :image,
    :parent_id,
    :state
  ]

  schema "taxon" do
    field :slug, :string
    field :title, :string
    field :subtitle, :string
    field :description, :string, default: ""
    field :featured, :boolean
    field :body, :string
    field :rich_text, {:array, :map}
    field :image, :string
    embeds_many :images, Buzzcms.EmbeddedSchema.ImageItem, on_replace: :raise
    embeds_many :breadcrumbs, Buzzcms.EmbeddedSchema.TaxonBreadcrumb
    embeds_one :seo, Buzzcms.EmbeddedSchema.Seo, on_replace: :update
    has_many :taxons, Buzzcms.Schema.Taxon, foreign_key: :parent_id
    belongs_to :taxonomy, Buzzcms.Schema.Taxonomy
    belongs_to :parent, Buzzcms.Schema.Taxon
    field :is_root, :boolean
    field :entries_count, :integer
    field :path, Ltree
    field :slug_path, Ltree
    field :level, :integer
    field :state, :string
    field :created_at, :utc_datetime
    field :modified_at, :utc_datetime
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> cast_embed(:seo)
    |> cast_embed(:images)
    |> validate_required(@required_fields)
    |> unique_constraint(:slug, name: :taxon_slug_unique)
  end
end
