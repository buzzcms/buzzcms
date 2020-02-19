defmodule BuzzcmsWeb.ImageResolver do
  @schema Buzzcms.Schema.Image

  @filter_definition [
    fields: [
      name: FilterParser.StringFilterInput,
      remote_url: FilterParser.StringFilterInput
    ]
  ]

  use BuzzcmsWeb.Resolver
end
