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
    Histogram.snapshot |> DataManager.Broadcaster.sync_notify
    Histogram.reset
    frequency = Application.get_env(:data_manager, :update_frequency)
    Process.send_after(self, :get_histogram, frequency)
    Logger.info "Update again in: #{inspect frequency}"
    {:noreply, state}
  end

  def notify(key, datapoint, value) do
    %{
      metric: key,
      datapoint: datapoint,
      value: value,
      extra: nil
    } |> DataManager.Broadcaster.sync_notify
  end
end
