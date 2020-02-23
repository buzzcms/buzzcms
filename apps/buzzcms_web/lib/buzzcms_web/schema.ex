defmodule BuzzcmsWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias BuzzcmsWeb.Data

  import_types(Absinthe.Type.Custom)
  import_types(BuzzcmsWeb.Schema.Common)
  import_types(BuzzcmsWeb.Schema.Taxonomies)
  import_types(BuzzcmsWeb.Schema.Taxons)
  import_types(BuzzcmsWeb.Schema.EntryTypes)
  import_types(BuzzcmsWeb.Schema.Entries)
  import_types(BuzzcmsWeb.Schema.EntryTaxons)
  import_types(BuzzcmsWeb.Schema.EntrySelectValues)
  import_types(BuzzcmsWeb.Schema.EntryTypeTaxonomies)
  import_types(BuzzcmsWeb.Schema.EntryTypeFields)
  import_types(BuzzcmsWeb.Schema.Fields)
  import_types(BuzzcmsWeb.Schema.FieldValues)
  import_types(BuzzcmsWeb.Schema.Images)
  import_types(BuzzcmsWeb.Schema.Products)
  import_types(BuzzcmsWeb.Schema.Variants)
  import_types(BuzzcmsWeb.Schema.OptionTypes)
  import_types(BuzzcmsWeb.Schema.OptionValues)

  query do
    import_fields(:node_field)
    import_fields(:entry_type_queries)
    import_fields(:taxonomy_queries)
    import_fields(:taxon_queries)
    import_fields(:entry_queries)
    import_fields(:product_queries)
    import_fields(:variant_queries)
    import_fields(:option_type_queries)
    import_fields(:option_value_queries)
    import_fields(:field_queries)
    import_fields(:field_value_queries)
    import_fields(:image_queries)
  end

  mutation do
    import_fields(:entry_type_mutations)
    import_fields(:taxonomy_mutations)
    import_fields(:taxon_mutations)
    import_fields(:entry_mutations)
    import_fields(:product_mutations)
    import_fields(:variant_mutations)
    import_fields(:option_type_mutations)
    import_fields(:option_value_mutations)
    import_fields(:field_mutations)
    import_fields(:field_value_mutations)
    import_fields(:entry_taxon_mutations)
    import_fields(:entry_select_value_mutations)
    import_fields(:entry_type_taxonomy_mutations)
    import_fields(:entry_type_field_mutations)
    import_fields(:image_mutations)
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Data, Data.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
