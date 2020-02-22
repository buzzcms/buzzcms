defmodule BuzzcmsWeb.EntryTypeResolver do
  @schema Buzzcms.Schema.EntryType
  @filter_definition [
    fields: [
      {:code, FilterParser.StringFilterInput},
      {:is_product, FilterParser.BooleanFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
