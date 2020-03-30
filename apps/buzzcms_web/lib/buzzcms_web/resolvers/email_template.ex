defmodule BuzzcmsWeb.EmailTemplateResolver do
  @schema Buzzcms.Schema.EmailTemplate

  @filter_definition [
    fields: [
      {:code, FilterParser.StringFilterInput},
      {:is_system, FilterParser.BooleanFilterInput},
      {:subject, FilterParser.StringFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
