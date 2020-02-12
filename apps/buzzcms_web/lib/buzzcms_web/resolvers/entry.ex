defmodule BuzzcmsWeb.EntryResolver do
  @schema Buzzcms.Schema.Entry
  @filter_definition [
    {:slug, :string_filter_input},
    {:title, :string_filter_input},
    {:entry_type_id, :id_filter_input},
    {:taxon_id, :id_filter_input},
    {:state, :string_filter_input}
  ]

  use BuzzcmsWeb.Resolver
end
