defmodule BuzzcmsWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      BuzzcmsWeb.Endpoint,
      %{
        id: :my_cache_id,
        start: {Cachex, :start_link, [:my_cache, []]}
      }
      # Starts a worker by calling: BuzzcmsWeb.Worker.start_link(arg)
      # {BuzzcmsWeb.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BuzzcmsWeb.Supervisor]

    :ok =
      :telemetry.attach(
        "repo-query-handler-id",
        [:buzzcms, :repo, :query],
        &Buzzcms.Telemetry.handle_event/4,
        %{}
      )

    # :ok =
    #   :telemetry.attach(
    #     "absinthe-handler-id",
    #     [:absinthe, :execute, :operation, :start],
    #     &Buzzcms.Telemetry.handle_event/4,
    #     %{}
    #   )

    :ok =
      :telemetry.attach_many(
        :buzzcms,
        [
          [:absinthe, :execute, :operation, :start],
          [:absinthe, :resolve, :field, :stop],
          [:absinthe, :execute, :operation, :stop]
        ],
        &Buzzcms.Telemetry.handle_event/4,
        []
      )

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BuzzcmsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
