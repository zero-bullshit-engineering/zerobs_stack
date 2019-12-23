defmodule ZerobsStack.RateLimitPlug do
  import Plug.Conn

  def init(_opts) do
    []
  end

  def call(conn, _opts) do
    case ExRated.check_rate(Ecto.UUID.generate(), 10_000, 5) do
      {:ok, _} -> conn
      {:error, _} -> conn |> send_resp(503, "Rate limit reached") |> halt
    end
  end
end
