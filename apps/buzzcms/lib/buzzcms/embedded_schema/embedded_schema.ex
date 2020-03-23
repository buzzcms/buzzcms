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

defmodule Buzzcms.EmbeddedSchema.Heading do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false

  embedded_schema do
    field :title, :string
    field :subtitle, :string
  end

  def changeset(schema, params) do
    schema |> cast(params, [:title, :subtitle])
  end
end

defmodule Buzzcms.EmbeddedSchema.Seo do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false

  embedded_schema do
    field :title, :string
    field :description, :string
    field :keywords, {:array, :string}
  end

  def changeset(schema, params) do
    schema |> cast(params, [:title, :description, :keywords])
  end
end
