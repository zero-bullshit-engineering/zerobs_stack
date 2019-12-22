defmodule ZerobsStack.ETSMeasurements do
  def measure_ets() do
    :ets.all()
    |> Enum.map(&:ets.info/1)
    |> Enum.each(fn measurement ->
      size = Keyword.get(measurement, :size)
      memory = Keyword.get(measurement, :memory)
      name = Keyword.get(measurement, :name)

      :telemetry.execute([:ets, :statistics], %{size: size, memory: memory}, %{name: name})
    end)
  end
end
