defmodule CpuMon.Client do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.send_after(self, :get_metrics, 5000)
    {:ok, %{}}
  end

  def handle_info(:get_metrics, state) do
    load =
      :cpu_sup.util([:per_cpu, :detailed])
      |> Enum.map(fn({cpu, busy, idle, _misc}) ->
        b = busy |> Enum.reduce(0, fn({_k, v}, acc) -> acc+v end)
        i = idle |> Enum.reduce(0, fn({_k, v}, acc) -> acc+v end)
        %{cpu: cpu, busy: b, idle: i}
      end)
    Logger.info("Current Load: #{inspect load}")
    Enum.each(load, fn(e) ->
      CpuMon.Broadcaster.sync_notify(e)
    end)
    Process.send_after(self, :get_metrics, 5000)
    {:noreply, state}
  end

end
