defmodule ZerobsStack.HTTP do
  defmacro __using__(_) do
    quote do
      use Tesla

      plug(Tesla.Middleware.Telemetry)
    end
  end
end
