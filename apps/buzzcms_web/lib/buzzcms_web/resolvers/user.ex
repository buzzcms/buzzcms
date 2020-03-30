defmodule BuzzcmsWeb.UserResolver do
  @schema Buzzcms.Schema.User

  @filter_definition [
    fields: [
      {:email, FilterParser.StringFilterInput},
      {:nickname, FilterParser.StringFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
