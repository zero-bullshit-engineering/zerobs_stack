defmodule ZerobsStack.LoadShedPlug do
  import Plug.Conn
  require Logger

  def init(_opts) do
    []
  end

  def call(conn, _opts) do
    flag_name =
      "#{conn.private.phoenix_controller}_#{conn.private.phoenix_action}_disabled"
      |> String.replace(".", "_")
      |> String.downcase()

    if FunWithFlags.enabled?(String.to_atom(flag_name)) do
      conn
      |> send_resp(503, "Load shedding in progress")
      |> halt

      # TODO: make this somehow render a fallback controller
    else
      conn
    end
  end
end
