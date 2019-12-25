defmodule ZerobsStack.LoadShedPlug do
  defstruct error_controller: ZerobsStack.ErrorController

  import Plug.Conn
  require Logger

  def init(opts = %__MODULE__{}) do
    opts
  end

  def call(conn, opts) do
    # TODO: Implement user/group based loadshed
    flag_name =
      "#{conn.private.phoenix_controller}_#{conn.private.phoenix_action}_disabled"
      |> String.replace(".", "_")
      |> String.downcase()

    if FunWithFlags.enabled?(String.to_atom(flag_name)) do
      :telemetry.execute([:zerobs, :loadshed, :occured], %{value: 1}, %{key: flag_name})

      apply(opts.error_controller, :call, [conn, {:error, :load_shedding}])
      |> halt
    else
      :telemetry.execute([:zerobs, :loadshed, :skipped], %{value: 1}, %{key: flag_name})
      conn
    end
  end
end
