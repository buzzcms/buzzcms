defmodule BuzzcmsWeb.EmailSenderResolver do
  @schema Buzzcms.Schema.EmailSender

  @filter_definition [
    fields: [
      {:email, FilterParser.StringFilterInput},
      {:name, FilterParser.StringFilterInput},
      {:provider, FilterParser.StringFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
