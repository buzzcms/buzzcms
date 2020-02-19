defmodule BuzzcmsWeb.EntryTypeResolver do
  @schema Buzzcms.Schema.EntryType
  @filter_definition [
    fields: [
      code: FilterParser.StringFilterInput
    ]
  ]

  use BuzzcmsWeb.Resolver
end
