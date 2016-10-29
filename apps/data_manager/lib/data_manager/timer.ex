defmodule DataManager.Timer do
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.send_after(self, :get_histogram, 0)
    {:ok, %{}}
  end

  def handle_info(:get_histogram, state) do
    Exmetrics.snapshot |> Map.get(:guages, %{}) |> Enum.each(fn {k,v} ->
      [metric, datapoint] = String.split(k, ".", parts: 2)
      %{
        metric: metric,
        datapoint: datapoint,
        value: v
      } |> DataManager.Broadcaster.sync_notify
    end)
    Process.send_after(self, :get_histogram, 5*60000)
    {:noreply, state}
  end
end
