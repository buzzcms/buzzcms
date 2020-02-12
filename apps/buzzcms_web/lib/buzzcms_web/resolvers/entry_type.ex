defmodule BuzzcmsWeb.EntryTypeResolver do
  @schema Buzzcms.Schema.EntryType
  @filter_definition [
    {:code, :string_filter_input}
  ]

  use BuzzcmsWeb.Resolver
end
