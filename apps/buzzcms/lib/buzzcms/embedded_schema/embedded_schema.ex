defmodule Buzzcms.EmbeddedSchema.Taxonomy do
  use Ecto.Schema
  @primary_key false

  embedded_schema do
    field :id, :integer
    field :code, :string
    field :display_name, :string
  end
end

defmodule Buzzcms.EmbeddedSchema.TaxonBreadcrumb do
  use Ecto.Schema
  @primary_key false

  embedded_schema do
    field :id, :integer
    field :slug, :string
    field :title, :string
    embeds_one :taxonomy, Buzzcms.EmbeddedSchema.Taxonomy, on_replace: :update
  end
end

