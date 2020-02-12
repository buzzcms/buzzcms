defmodule BuzzcmsWeb.FieldResolver do
  @schema Buzzcms.Schema.Field
  @filter_definition [
    {:code, :string_filter_input}
  ]

  use BuzzcmsWeb.Resolver
end
