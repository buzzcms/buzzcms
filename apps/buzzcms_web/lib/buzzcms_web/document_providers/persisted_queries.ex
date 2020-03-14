defmodule BuzzcmsWeb.Schema.DocumentProvider.PersistedQueries do
  @behaviour Absinthe.Plug.DocumentProvider

  # TODO: Store this into database
  @documents %{}

  def process(request, _) do
    do_process(request)
  end

  defp do_process(%{params: %{"id" => document_key}} = request) do
    case Map.get(@documents, document_key |> String.to_atom()) do
      nil ->
        {:cont, request}

      document ->
        {:halt, %{request | document: document, document_provider_key: document_key}}
    end
  end

  defp do_process(request) do
    {:cont, request}
  end

  def pipeline(%{pipeline: as_configured}), do: as_configured
end
