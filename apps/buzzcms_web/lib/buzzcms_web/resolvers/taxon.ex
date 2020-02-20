defmodule BuzzcmsWeb.TaxonResolver do
  alias FilterParser.{IdFilterInput, StringFilterInput}

  @schema Buzzcms.Schema.Taxon

  @filter_definition [
    fields: [
      {:id, IdFilterInput},
      {:slug, StringFilterInput},
      {:title, StringFilterInput},
      # {:is_root, IdFilterInput},
      {:parent_id, IdFilterInput},
      {:state, StringFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
