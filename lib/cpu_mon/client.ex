defmodule Cicada.CpuMon.Client do
  use GenServer
  require Logger
  alias Cicada.{EventManager, CpuMon}

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def dispatch(event) do
    EventManager.dispatch(CpuMon, event)
  end

  def init(:ok) do
    Process.send_after(self(), :get_metrics, 5000)
    {:ok, %{}}
  end

  def handle_info(:get_metrics, state) do
    cpus =
      :cpu_sup.util([:per_cpu, :detailed])
      |> Enum.map(fn({cpu, busy, idle, _misc}) ->
        b = busy |> Enum.reduce(0, fn({_k, v}, acc) -> acc+v end)
        i = idle |> Enum.reduce(0, fn({_k, v}, acc) -> acc+v end)
        %CpuMon.Cpu{cpu: cpu, busy: b, idle: i} |> CpuMon.Client.dispatch
      end)
    Process.send_after(self(), :get_metrics, 5000)
    {:noreply, %CpuMon.State{cpus: cpus}}
  end

  def handle_call(:register, {pid, _ref}, state) do
    Registry.register(EventManager.Registry, CpuMon, pid)
    {:reply, :ok, state}
  end
end
