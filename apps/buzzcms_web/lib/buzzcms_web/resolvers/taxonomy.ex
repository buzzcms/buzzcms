defmodule BuzzcmsWeb.TaxonomyResolver do
  @schema Buzzcms.Schema.Taxonomy
  @filter_definition [
    fields: [
      {:id, FilterParser.IdFilterInput},
      {:code, FilterParser.StringFilterInput},
      {:display_name, FilterParser.StringFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
