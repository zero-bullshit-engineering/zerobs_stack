defmodule ZerobsStack.LoadShedPlug do
  import Plug.Conn
  require Logger

  def init(_opts) do
    []
  end

  def call(conn, _opts) do
    # TODO: Implement user/group based loadshed
    flag_name =
      "#{conn.private.phoenix_controller}_#{conn.private.phoenix_action}_disabled"
      |> String.replace(".", "_")
      |> String.downcase()

    if FunWithFlags.enabled?(String.to_atom(flag_name)) do
      :telemetry.execute([:zerobs, :loadshed, :occured], %{value: 1}, %{key: flag_name})

      conn
      |> send_resp(503, "Load shedding in progress")
      |> halt

      # TODO: make this somehow render a fallback controller
    else
      :telemetry.execute([:zerobs, :loadshed, :skipped], %{value: 1}, %{key: flag_name})
      conn
    end
  end
end
