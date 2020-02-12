defmodule BuzzcmsWeb.TaxonResolver do
  @schema Buzzcms.Schema.Taxon
  @filter_definition [
    {:slug, :string_filter_input},
    {:title, :string_filter_input},
    {:taxonomy_id, :id_filter_input}
  ]

  use BuzzcmsWeb.Resolver
end
