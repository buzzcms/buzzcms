defmodule BuzzcmsWeb.EntryResolver do
  alias FilterParser.{IdFilterInput, StringFilterInput}

  @schema Buzzcms.Schema.Entry

  @filter_definition [
    fields: [
      {:id, IdFilterInput},
      {:slug, StringFilterInput},
      {:title, StringFilterInput},
      {:entry_type_id, IdFilterInput},
      {:taxon_id, IdFilterInput},
      {:state, StringFilterInput}
    ],
    foreign_fields: [
      taxons_id:
        {Buzzcms.Schema.EntryTaxon, [foreign_key: :entry_id, foreign_filter_field: :taxon_id]}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
