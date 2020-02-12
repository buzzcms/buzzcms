defmodule BuzzcmsWeb.TaxonomyResolver do
  @schema Buzzcms.Schema.Taxonomy
  @filter_definition [
    {:code, :string_filter_input}
  ]

  use BuzzcmsWeb.Resolver
end
