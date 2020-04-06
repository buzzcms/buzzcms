defmodule Buzzcms.Schema.EntryType do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:code, :display_name]
  @optional_fields [:is_product]

  schema "entry_type" do
    field :code, :string
    field :display_name, :string
    field :is_product, :boolean, default: false
    embeds_one :config, Buzzcms.EmbeddedSchema.EntryTypeConfig, on_replace: :update
    many_to_many :taxonomies, Buzzcms.Schema.Taxonomy, join_through: "entry_type_taxonomy"
    many_to_many :fields, Buzzcms.Schema.Field, join_through: "entry_type_field"
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
    |> cast_embed(:config)
  end

  def edit_changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> unique_constraint(:code)
    |> put_embed(:config, params[:config])
  end
end
