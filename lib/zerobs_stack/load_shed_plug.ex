defmodule ZerobsStack.LoadShedPlug do
  @moduledoc """
  This Plug allows dynamic load shedding via feature flags. To use it include `plug ZerobsStack.LoadShedPlug, %ZerobsStack.LoadShedPlug{}` in your `ProjectWeb.ex` controller function definition at the end of the `quote do` block. 

  It makes a feature flag called `elixir_project_page_controller_index_disabled` for a controller named `Elixir.Project.PageController.index` available via FunWithFlags.

  You can configure your own error handler by passing `error_controller` to the initialization: ` plug ZerobsStack.LoadShedPlug, %ZerobsStack.LoadShedPlug{error_controller: MyErrorController}`. It calls `MyErrorController.call(conn, {:error, :load_shedding})` so you can render a custom response.
  """

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
