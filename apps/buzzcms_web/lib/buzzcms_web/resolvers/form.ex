defmodule BuzzcmsWeb.FormResolver do
  @schema Buzzcms.Schema.Form

  @filter_definition [
    fields: [
      {:code, FilterParser.StringFilterInput},
      {:display_name, FilterParser.StringFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
