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

  def create(
        %{data: data},
        %{context: _}
      ) do
    result =
      struct(@schema)
      |> @schema.changeset(data)
      |> Repo.insert()

    case result do
      {:ok, result} ->
        {:ok, %{result: %{node: Repo.get(@schema, result.id)}}}

      {:error, changeset = %Ecto.Changeset{}} ->
        {:error, %{message: BuzzcmsWeb.Helpers.error_text(changeset)}}

      {:error, _} ->
        {:error, "Unknown errors"}
    end
  end
end
