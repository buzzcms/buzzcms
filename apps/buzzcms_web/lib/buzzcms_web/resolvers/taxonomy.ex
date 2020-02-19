defmodule BuzzcmsWeb.TaxonomyResolver do
  @schema Buzzcms.Schema.Taxonomy
  @filter_definition [
    fields: [
      code: FilterParser.StringFilterInput
    ]
  ]
  use BuzzcmsWeb.Resolver
end
