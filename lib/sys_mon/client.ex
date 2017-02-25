defmodule Cicada.SysMon.Client do
  use GenServer
  require Logger
  alias Cicada.{EventManager, SysMon}

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def dispatch(event) do
    EventManager.dispatch(SysMon, event)
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
        %SysMon.Cpu{cpu: cpu, busy: b, idle: i} |> SysMon.Client.dispatch
      end)
    {total, allocated, _worst} = :memsup.get_memory_data()
    mem = %SysMon.Memory{total: total, allocated: allocated} |> SysMon.Client.dispatch
    Process.send_after(self(), :get_metrics, 5000)
    {:noreply, %SysMon.State{cpus: cpus, memory: mem}}
  end

  def handle_call(:register, {pid, _ref}, state) do
    Registry.register(EventManager.Registry, SysMon, pid)
    {:reply, :ok, state}
  end
end
