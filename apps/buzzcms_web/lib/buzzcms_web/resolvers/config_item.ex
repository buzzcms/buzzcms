defmodule BuzzcmsWeb.ConfigItemResolver do
  @schema Buzzcms.Schema.ConfigItem

  @filter_definition [
    fields: [
      {:code, FilterParser.StringFilterInput},
      {:display_name, FilterParser.StringFilterInput},
      {:type, FilterParser.StringFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
