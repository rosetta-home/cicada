defmodule Cicada.DataManager.Client do
  use GenServer
  require Logger
  alias Cicada.{DataManager, EventManager, DeviceManager}
  alias Cicada.DataManager.Histogram


  defmodule History do
    defstruct datapoint: nil,
      metric: nil,
      values: []
  end

  defmodule Device do
    defstruct id: nil,
      history: []
  end

  defmodule State do
    defstruct sensors: []
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def create_histogram(id, map, _state) do
    name = :"Histogram-#{id}"
    res = case Histogram.start_device(name, map) do
      :already_started -> :already_started
      {:ok, pid} ->
        Process.monitor(map.interface_pid)
        :ok
    end
    Histogram.Device.records(name, id, map.state)
    res
  end

  def send_metric(device, state) do
    id = device.interface_pid |> Atom.to_string
    create_histogram(id, device, state)
  end

  def init(:ok) do
    DeviceManager.register
    {:ok, %State{}}
  end

  def handle_info({:DOWN, ref, :process, {id, node}, reason}, state) do
    Logger.info "DataManager Client: Process down #{inspect ref}: #{inspect id} : #{inspect reason}"
    id = :"Histogram-#{id}"
    case Registry.lookup(Cicada.DataManager.Registry, id) do
      [{_pid, {device, pid}}| tail] ->
        Logger.info "Lookup PID: #{inspect pid} #{inspect device}"
        pid |> Process.exit(:kill)
        Registry.unregister(Cicada.DataManager.Registry, id)
      [] -> nil
    end
    {:noreply, state}
  end

  def handle_info(%DeviceManager.Device{} = device, state) do
    {:noreply, %State{state | sensors: device |> send_metric(state)}}
  end

  def handle_info(_device, state), do: {:noreply, state}

  def handle_call(:register, {pid, _ref}, state) do
    Registry.register(EventManager.Registry, DataManager, pid)
    {:reply, :ok, state}
  end

  def dispatch(event) do
    EventManager.dispatch(DataManager, event)
  end

end
