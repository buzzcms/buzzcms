defmodule BuzzcmsWeb.EntryResolver do
  import Ecto.Query

  @schema Buzzcms.Schema.Entry
  @filter_definition [
    {:slug, :string_filter_input},
    {:title, :string_filter_input},
    {:entry_type_id, :id_filter_input},
    {:state, :string_filter_input},
    {:taxon_id,
     {:ref_id_filter_input,
      Buzzcms.Schema.Entry
      |> join(:inner, [e], et in Buzzcms.Schema.EntryTaxon, on: e.id == et.entry_id)}}
    # {:x, }
  ]

  use BuzzcmsWeb.Resolver
end
