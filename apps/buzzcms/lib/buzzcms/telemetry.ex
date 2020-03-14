defmodule Buzzcms.Telemetry do
  require Logger

  def handle_event([:buzzcms, :repo, :query] = event_name, measurements, metadata, _config) do
    %{
      event_name: event_name,
      query: metadata.query,
      duration:
        case measurements do
          %{total_time: total_time} -> total_time / 1_000_000
          _ -> nil
        end
    }
    |> inspect()
    |> Logger.debug()
  end

  def handle_event(
        [:absinthe | _] = event_name,
        measurements,
        metadata,
        _config
      ) do
    result = %{
      event_name: event_name,
      measurements: measurements,
      id: metadata.id,
      metadata: Map.keys(metadata),
      start_time:
        case metadata do
          %{start_time: start_time} -> start_time
          _ -> nil
        end,
      duration:
        case measurements do
          %{duration: duration} -> duration / 1_000_000
          _ -> nil
        end,
      fields:
        case metadata do
          %{resolution: %{definition: _definition, source: _source} = resolution} ->
            Absinthe.Resolution.path(resolution)

          _ ->
            nil
        end
    }

    case result do
      %{duration: duration, fields: ["entries"]} when duration > 1 -> result
      %{event_name: [:absinthe, :execute, :operation, :start]} -> result
      %{event_name: [:absinthe, :execute, :operation, :stop]} -> result
      _ -> nil
    end
    |> inspect()
    |> Logger.debug()
  end
end
