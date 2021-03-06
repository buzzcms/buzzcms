defmodule BuzzcmsWeb.FieldValueResolver do
  @schema Buzzcms.Schema.FieldValue

  @filter_definition [
    fields: [
      {:code, FilterParser.StringFilterInput},
      {:display_name, FilterParser.StringFilterInput},
      {:field_id, FilterParser.IdFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
