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
      Plug.Cowboy.child_spec(scheme: :http, plug: ZerobsStack.AdminPanel, options: [port: 4444]),
      {TelemetryMetricsPrometheus.Core, [metrics: metrics()]}
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
      counter("http.request.count"),
      distribution("phoenix.router_dispatch.stop.duration",
        buckets: [50, 100, 250, 1000, 2500, 50000],
        tags: [:route]
      ),
      sum("http.request.payload_size", unit: :byte),
      last_value("vm.memory.total", unit: :byte)
    ]
end
