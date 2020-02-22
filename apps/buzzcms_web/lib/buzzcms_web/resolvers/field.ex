defmodule BuzzcmsWeb.FieldResolver do
  @schema Buzzcms.Schema.Field

  @filter_definition [
    fields: [
      {:code, FilterParser.StringFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
