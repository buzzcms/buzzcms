defmodule BuzzcmsWeb.VariantResolver do
  @schema Buzzcms.Schema.Variant
  @filter_definition [
    fields: [
      {:is_master, FilterParser.BooleanFilterInput}
    ]
  ]
  use BuzzcmsWeb.Resolver
end
