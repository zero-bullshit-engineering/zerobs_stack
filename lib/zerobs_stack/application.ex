defmodule ZerobsStack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Telemetry.Metrics

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: ZerobsStack.Worker.start_link(arg)
      # {ZerobsStack.Worker, arg}
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: ZerobsStack.AdminPanel,
        options: [port: 4444, transport_options: [num_acceptors: 32]]
      ),
      #      ExRated.child_spec([{:timeout, 60_000}]),
      {TelemetryMetricsPrometheus.Core, [metrics: metrics()]},
      {:telemetry_poller, measurements: [{ZerobsStack.ETSMeasurements, :measure_ets, []}]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ZerobsStack.Supervisor]

    :ok =
      :telemetry.attach(
        "zerobs-stack-logger",
        [:web],
        &ZerobsStack.TelemetryLogger.handle_event/4,
        nil
      )

    Supervisor.start_link(children, opts)
  end

  defp metrics,
    do: [
      counter("tesla.request.request_time"),
      counter("http.request.count"),
      distribution("phoenix.router_dispatch.stop.duration",
        buckets: [0.0001, 0.0005, 0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 5],
        unit: {:native, :second},
        tags: [:route]
      ),
      distribution("stacker.repo.query.total_time",
        buckets: [0.0001, 0.001, 0.01, 0.1, 1],
        unit: {:native, :second},
        name: "application_repo_query_total_time"
      ),
      sum("http.request.payload_size", unit: :byte),
      last_value("ets.statistics.size", tags: [:name]),
      last_value("ets.statistics.memory", tags: [:name]),
      last_value("vm.memory.total", unit: :byte),
      last_value("vm.total_run_queue_lengths.total"),
      last_value("vm.total_run_queue_lengths.cpu"),
      last_value("vm.total_run_queue_lengths.io"),
      last_value(
        "phoenix_plug_duration",
        event_name: [:phoenix, :router_dispatch, :stop],
        measurement: :duration,
        unit: {:native, :second},
        tags: [:plug]
      )
    ]
end
