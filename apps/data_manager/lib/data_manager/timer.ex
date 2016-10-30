defmodule DataManager.Timer do
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.send_after(self, :get_histogram, 100)
    {:ok, %{}}
  end

  def handle_info(:get_histogram, state) do
    Histogram.snapshot |> IO.inspect |> Enum.each(fn {k,v} ->
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
    Process.send_after(self, :get_histogram, 15*60000)
    {:noreply, state}
  end
end
