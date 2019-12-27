defmodule ZerobsStack.ReadinessPlug do
  @moduledoc """
  This allows for automatic kubernetes healthchecks via a list of configured `{Module, Function, Arguments}` tuples.
  All configured MFAs are executed and checked against the `{:ok, _}` tuple. If any of the check fails the Plug returns HTTP 500.
  """
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
