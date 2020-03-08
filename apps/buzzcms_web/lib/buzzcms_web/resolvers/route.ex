defmodule BuzzcmsWeb.RouteResolver do
  @schema Buzzcms.Schema.Route

  @filter_definition [
    fields: [
      {:name, FilterParser.StringFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
