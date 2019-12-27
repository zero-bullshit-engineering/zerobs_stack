defmodule ZerobsStack.ReadinessPlug do
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, opts) do
    mfas = Application.get_env(:zerobs_stack, :health_checks, [])

    for {module, function, args} <- mfas do
      Logger.debug("[health] Checking #{module}.#{function} with #{inspect(args)}")
      {:ok, _} = apply(module, function, args)
    end

    conn
    |> send_resp(200, "ok")
  end
end
