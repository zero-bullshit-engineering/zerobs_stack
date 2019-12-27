defmodule ZerobsStack.RateLimitPlug do
  @moduledoc """
  This plug allows for rate limiting HTTP calls to your application. It can be used in your controllers or the routing pipeline to e.g. rate limit per-IP traffic across your whole application and further restrict specific routes (e.g. login/password reset) further. A key to rate limit on can be chosen dynamically from the conn to allow for flexible limits. 

  ```
  plug ZerobsStack.RateLimitPlug, %ZerobsStack.RateLimitPlug{
    name: "PageController",
    identifier: [:private, :phoenix_format]
  }
  ```

  This sample show the usage in an exemplary PageController. The plug rate limits on 10 requests/60 seconds (default) and chooses the `private/phoenix_format` key from the conn. As with `ZerobsStack.LoadShedPlug` an `error_controller` key can be passed. This plug calls `MyErrorController.call(conn, {:error, :rate_limit_reached})` so you can render a custom response.
  """

  defstruct name: nil,
            limit_times: 10,
            limit_seconds: 60,
            identifier: nil,
            error_controller: ZerobsStack.ErrorController

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

        apply(opts.error_controller, :call, [conn, {:error, :rate_limit_reached}])
        |> halt
    end
  end
end
