defmodule DataManager.Timer do
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.send_after(self, :get_histogram, 1*60000)
    {:ok, %{}}
  end

  def handle_info(:get_histogram, state) do
    snapshot = Histogram.snapshot
    snapshot |> DataManager.Broadcaster.sync_notify
    snapshot |> Enum.each(fn {k,v} ->
      Enum.each(v, fn {datapoint, value} ->
        %{
          metric: k,
          datapoint: datapoint,
          value: value,
          extra: nil
        } |> DataManager.Broadcaster.sync_notify
      end)
    end)
    Histogram.reset
    frequency = Application.get_env(:data_manager, :update_frequency)
    Process.send_after(self, :get_histogram, frequency)
    {:noreply, state}
  end
end
