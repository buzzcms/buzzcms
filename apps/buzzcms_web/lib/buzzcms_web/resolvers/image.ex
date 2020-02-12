defmodule BuzzcmsWeb.ImageResolver do
  @schema Buzzcms.Schema.Image
  @filter_definition [
    {:name, :string_filter_input},
    {:remote_url, :string_filter_input}
  ]

  use BuzzcmsWeb.Resolver
end
