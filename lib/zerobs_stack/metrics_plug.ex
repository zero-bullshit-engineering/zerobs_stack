defmodule MetricsPlug do
  import Plug.Conn

  def init(_) do
    []
  end

  def call(conn, _) do
    conn
    |> send_resp(200, TelemetryMetricsPrometheus.Core.scrape())
  end
end
