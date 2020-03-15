defmodule BuzzcmsWeb.SubscriberResolver do
  @schema Buzzcms.Schema.Subscriber

  @filter_definition [
    fields: [
      {:email, FilterParser.StringFilterInput},
      {:phone, FilterParser.StringFilterInput},
      {:name, FilterParser.StringFilterInput},
      {:form_id, FilterParser.IdFilterInput},
      {:created_at, FilterParser.DateTimeFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver
end
