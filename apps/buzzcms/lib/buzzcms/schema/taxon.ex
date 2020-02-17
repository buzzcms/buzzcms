defmodule Buzzcms.Schema.Taxon do
  use Ecto.Schema
  import Ecto.Changeset
  alias EctoLtree.LabelTree, as: Ltree

  @required_fields [:slug, :title, :taxonomy_id]
  @optional_fields [:description, :body, :rich_text, :parent_id]

  schema "taxon" do
    field :slug, :string
    field :title, :string
    field :description, :string
    field :body, :string
    field :rich_text, {:array, :map}
    has_many :taxons, Buzzcms.Schema.Taxon, foreign_key: :parent_id
    belongs_to :taxonomy, Buzzcms.Schema.Taxonomy
    belongs_to :parent, Buzzcms.Schema.Taxon
    field :is_root, :boolean
    field :path, Ltree
    field :level, :integer
    field :state, :string
    field :created_at, :utc_datetime
    field :modified_at, :utc_datetime
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:slug, name: :taxon_slug_unique)
  end
end
