defmodule ZerobsStack.RateLimitPlug do
  defstruct name: nil, limit_times: 10, limit_seconds: 60, identifier: nil
  import Plug.Conn
  require Logger

  def init(opts = %__MODULE__{}) do
    Logger.debug("Initialized ratelimit with #{inspect(opts)}")
    opts
  end

  def call(conn, opts) do
    key =
      if opts.identifier do
        id = conn |> Map.from_struct() |> get_in(opts.identifier) |> :erlang.phash2() |> to_string
        opts.name <> id
      else
        opts.name
      end

    Logger.debug("Checking rate limit for #{key}")

    case ExRated.check_rate(key, opts.limit_seconds * 1_000, opts.limit_times) do
      {:ok, _} ->
        :telemetry.execute([:zerobs, :ratelimit, :skipped], %{value: 1}, %{key: opts.name})
        conn

      {:error, _} ->
        :telemetry.execute([:zerobs, :ratelimit, :occured], %{value: 1}, %{key: opts.name})
        conn |> send_resp(503, "Rate limit reached") |> halt
    end
  end
end
